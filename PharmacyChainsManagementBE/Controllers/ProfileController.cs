using System;
using System.Linq;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Controllers;

[Authorize]
[ApiController]
[Route("api/v1/profile")]
public class ProfileController : ControllerBase
{
    private readonly PharmacyDbContext _context;

    public ProfileController(PharmacyDbContext context)
    {
        _context = context;
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
                joinedDate = user.CreatedAt
            })
            .FirstOrDefaultAsync(cancellationToken);

        return profile == null ? NotFound() : Ok(profile);
    }

    [HttpPut]
    public async Task<IActionResult> UpdateProfile(
        [FromBody] UpdateProfileRequest request,
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        if (userId == null)
        {
            return Unauthorized();
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
        user.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync(cancellationToken);
        return await GetProfile(cancellationToken);
    }

    private Guid? GetUserId()
    {
        var subject = User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? User.FindFirstValue("sub");
        return Guid.TryParse(subject, out var userId) ? userId : null;
    }
}

public sealed record UpdateProfileRequest(string FullName, string? Phone);
