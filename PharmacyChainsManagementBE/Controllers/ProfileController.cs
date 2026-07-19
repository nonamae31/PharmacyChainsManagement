using System;
using System.Linq;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Models;
using PharmacyChainsManagementBE.Services;
using System.ComponentModel.DataAnnotations;

namespace PharmacyChainsManagementBE.Controllers;

[Authorize]
[ApiController]
[Route("api/v1/profile")]
public class ProfileController : ControllerBase
{
    private readonly PharmacyDbContext _context;
    private readonly IPasswordHashingStrategy _passwordHashingStrategy;
    private readonly ICloudinaryService _cloudinaryService;

    public ProfileController(
        PharmacyDbContext context,
        IPasswordHashingStrategy passwordHashingStrategy,
        ICloudinaryService cloudinaryService)
    {
        _context = context;
        _passwordHashingStrategy = passwordHashingStrategy;
        _cloudinaryService = cloudinaryService;
    }

    [HttpGet]
    public async Task<IActionResult> GetProfile(CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        var profile = await _context.Users
            .AsNoTracking()
            .Include(user => user.Role)
            .Include(user => user.Branch)
            .Where(user => user.UserId == userId.Value)
            .Select(user => new
            {
                userId = user.UserId,
                fullName = user.FullName,
                email = user.Email,
                role = user.Role.RoleName,
                status = user.Status,
                phone = user.Phone,
                branchName = user.Branch != null ? user.Branch.BranchName : null,
                profilePhotoUri = user.ProfilePhotoUri,
                address = user.Address,
                dateOfBirth = user.DateOfBirth,
                gender = user.Gender,
                joinedDate = user.CreatedAt
            })
            .FirstOrDefaultAsync(cancellationToken);

        return profile == null ? NotFound() : Ok(profile);
    }

    [HttpPut]
    [EnableRateLimiting("ProfileUpdatePolicy")]
    public async Task<IActionResult> UpdateProfile(
        [FromBody] ProfileUpdateRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }
        if (request.DateOfBirth?.Date > DateTime.UtcNow.Date)
        {
            ModelState.AddModelError(nameof(request.DateOfBirth), "Date of birth cannot be in the future.");
            return ValidationProblem(ModelState);
        }

        if (string.IsNullOrWhiteSpace(request.FullName))
        {
            return BadRequest(new { message = "Full name is required." });
        }

        var user = await _context.Users
            .FirstOrDefaultAsync(item => item.UserId == userId.Value, cancellationToken);
        if (user == null)
        {
            return NotFound();
        }

        user.FullName = request.FullName.Trim();
        user.Phone = string.IsNullOrWhiteSpace(request.Phone) ? null : request.Phone.Trim();
        user.Address = string.IsNullOrWhiteSpace(request.Address) ? null : request.Address.Trim();
        user.DateOfBirth = request.DateOfBirth.HasValue
            ? DateTime.SpecifyKind(request.DateOfBirth.Value.Date, DateTimeKind.Utc)
            : null;
        user.Gender = string.IsNullOrWhiteSpace(request.Gender) ? null : request.Gender.Trim();
        user.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);
        return await GetProfile(cancellationToken);
    }

    [HttpPost("avatar")]
    [EnableRateLimiting("ProfileUpdatePolicy")]
    public async Task<IActionResult> UploadAvatar(
        [FromForm] IFormFile file,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null)
        {
            return Unauthorized();
        }
        if (file == null || file.Length == 0)
        {
            return BadRequest(new { message = "Select a profile image to upload." });
        }
        if (file.Length > 5 * 1024 * 1024)
        {
            return BadRequest(new { message = "Profile image cannot exceed 5 MB." });
        }
        var user = await _context.Users.FirstOrDefaultAsync(
            item => item.UserId == userId.Value,
            cancellationToken);
        if (user == null)
        {
            return NotFound();
        }

        var imageUrl = await _cloudinaryService.UploadImageAsync(file);
        if (string.IsNullOrWhiteSpace(imageUrl))
        {
            return Problem("Profile image upload failed.");
        }

        user.ProfilePhotoUri = imageUrl;
        user.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(cancellationToken);
        return await GetProfile(cancellationToken);
    }

    [HttpPost("change-password")]
    [EnableRateLimiting("ProfileUpdatePolicy")]
    public async Task<IActionResult> ChangePassword(
        [FromBody] ChangePasswordRequest request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        var userId = GetUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        var user = await _context.Users.FirstOrDefaultAsync(
            item => item.UserId == userId.Value,
            cancellationToken);
        if (user == null)
        {
            return NotFound();
        }
        if (!_passwordHashingStrategy.VerifyPassword(request.CurrentPassword, user.PasswordHash))
        {
            return BadRequest(new { message = "Current password is incorrect." });
        }
        if (_passwordHashingStrategy.VerifyPassword(request.NewPassword, user.PasswordHash))
        {
            return BadRequest(new { message = "New password must be different from the current password." });
        }

        user.PasswordHash = _passwordHashingStrategy.HashPassword(request.NewPassword);
        user.MustChangePassword = false;
        user.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync(cancellationToken);
        return Ok(new { message = "Password changed successfully." });
    }

    private Guid? GetUserId()
    {
        var subject = User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue("sub");
        return Guid.TryParse(subject, out var userId) ? userId : null;
    }
}

public sealed class ProfileUpdateRequest
{
    [Required, StringLength(150, MinimumLength = 2)]
    public string FullName { get; init; } = string.Empty;

    [StringLength(30), RegularExpression(@"^\+?[0-9]{9,15}$")]
    public string? Phone { get; init; }

    [StringLength(255)]
    public string? Address { get; init; }

    public DateTime? DateOfBirth { get; init; }

    [StringLength(10), RegularExpression("^(Male|Female|Other)$")]
    public string? Gender { get; init; }
}

public sealed class ChangePasswordRequest
{
    [Required]
    public string CurrentPassword { get; init; } = string.Empty;

    [Required, StringLength(100, MinimumLength = 8)]
    [RegularExpression(
        @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d])\S+$",
        ErrorMessage = "New password must contain uppercase, lowercase, number, and special character.")]
    public string NewPassword { get; init; } = string.Empty;
}
