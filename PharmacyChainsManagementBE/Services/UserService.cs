using System;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.DTOs.Users;
using PharmacyChainsManagementBE.Repositories;

namespace PharmacyChainsManagementBE.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;

        public UserService(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }

        public async Task<bool> UpdateProfileAsync(Guid userId, UpdateProfileRequest request, CancellationToken cancellationToken = default)
        {
            var fullName = request.FullName?.Trim();
            
            // If it becomes empty after trim
            if (string.IsNullOrEmpty(fullName))
            {
                fullName = null;
            }

            var rowsAffected = await _userRepository.UpdateProfilePartialAsync(
                userId, 
                fullName, 
                request.ProfilePhotoUri, 
                request.Address, 
                request.DateOfBirth, 
                request.Gender, 
                request.PhoneNumber,
                cancellationToken);
            return rowsAffected > 0;
        }

        public async Task<UserProfileDto?> GetProfileAsync(Guid userId, CancellationToken cancellationToken = default)
        {
            var user = await _userRepository.FindByIdAsync(userId, cancellationToken);
            if (user == null) return null;

            return new UserProfileDto
            {
                UserId = user.UserId,
                FullName = user.FullName ?? "",
                Email = user.Email,
                Phone = user.Phone,
                ProfilePhotoUri = user.ProfilePhotoUri,
                Address = user.Address,
                Gender = user.Gender,
                DateOfBirth = user.DateOfBirth
            };
        }
    }
}
