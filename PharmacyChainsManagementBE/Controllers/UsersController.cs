using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.Http;
using PharmacyChainsManagementBE.DTOs.Users;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Controllers
{
    [ApiController]
    [Route("api/users")]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly ICurrentUserService _currentUserService;
        private readonly ICloudinaryService _cloudinaryService;

        public UsersController(IUserService userService, ICurrentUserService currentUserService, ICloudinaryService cloudinaryService)
        {
            _userService = userService;
            _currentUserService = currentUserService;
            _cloudinaryService = cloudinaryService;
        }

        [HttpGet("profile")]
        [Authorize]
        [EnableRateLimiting("ProfileUpdatePolicy")]
        public async Task<IActionResult> GetProfile(CancellationToken cancellationToken)
        {
            var userId = _currentUserService.UserId;
            if (userId == null)
            {
                return Unauthorized(new ProblemDetails
                {
                    Status = StatusCodes.Status401Unauthorized,
                    Title = "Unauthorized",
                    Detail = "User ID not found in token."
                });
            }

            var profile = await _userService.GetProfileAsync(userId.Value, cancellationToken);
            if (profile == null)
            {
                return NotFound(new ProblemDetails
                {
                    Status = StatusCodes.Status404NotFound,
                    Title = "User not found",
                    Detail = "The requested user profile was not found."
                });
            }

            return Ok(new { data = profile, message = "Success" });
        }

        [HttpPatch("profile")]
        [Authorize]
        [EnableRateLimiting("ProfileUpdatePolicy")]
        public async Task<IActionResult> UpdateProfilePartial([FromBody] UpdateProfileRequest request, CancellationToken cancellationToken)
        {
            var userId = _currentUserService.UserId;
            if (userId == null)
            {
                return Unauthorized(new ProblemDetails
                {
                    Status = StatusCodes.Status401Unauthorized,
                    Title = "Unauthorized",
                    Detail = "User ID not found in token."
                });
            }

            if (request == null)
            {
                return BadRequest(new ProblemDetails
                {
                    Status = StatusCodes.Status400BadRequest,
                    Title = "Bad Request",
                    Detail = "Request body cannot be null."
                });
            }

            // At least one field must be provided to update
            if (request.FullName == null && request.ProfilePhotoUri == null && request.Address == null && request.Gender == null && request.DateOfBirth == null && request.PhoneNumber == null)
            {
                return BadRequest(new ProblemDetails
                {
                    Status = StatusCodes.Status400BadRequest,
                    Title = "Bad Request",
                    Detail = "At least one field must be provided to update."
                });
            }

            var success = await _userService.UpdateProfileAsync(userId.Value, request, cancellationToken);

            if (!success)
            {
                return NotFound(new ProblemDetails
                {
                    Status = StatusCodes.Status404NotFound,
                    Title = "User not found",
                    Detail = "The user to update was not found."
                });
            }

            return Ok(new { message = "Profile updated successfully." });
        }

        [HttpPost("profile/avatar")]
        [Authorize]
        [EnableRateLimiting("ProfileUpdatePolicy")]
        public async Task<IActionResult> UploadAvatar([FromForm] IFormFile file, CancellationToken cancellationToken)
        {
            var userId = _currentUserService.UserId;
            if (userId == null)
            {
                return Unauthorized(new ProblemDetails
                {
                    Status = StatusCodes.Status401Unauthorized,
                    Title = "Unauthorized",
                    Detail = "User ID not found in token."
                });
            }

            if (file == null || file.Length == 0)
            {
                return BadRequest(new ProblemDetails
                {
                    Status = StatusCodes.Status400BadRequest,
                    Title = "Bad Request",
                    Detail = "No file uploaded."
                });
            }

            var imageUrl = await _cloudinaryService.UploadImageAsync(file);

            if (string.IsNullOrEmpty(imageUrl))
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new ProblemDetails
                {
                    Status = StatusCodes.Status500InternalServerError,
                    Title = "Upload Failed",
                    Detail = "Failed to upload image to Cloudinary."
                });
            }

            var updateRequest = new UpdateProfileRequest { ProfilePhotoUri = imageUrl };
            var success = await _userService.UpdateProfileAsync(userId.Value, updateRequest, cancellationToken);

            if (!success)
            {
                return NotFound(new ProblemDetails
                {
                    Status = StatusCodes.Status404NotFound,
                    Title = "User not found",
                    Detail = "The user to update was not found."
                });
            }

            return Ok(new { message = "Avatar uploaded successfully.", profilePhotoUri = imageUrl });
        }
    }
}
