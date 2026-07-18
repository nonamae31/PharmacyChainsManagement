using System;
using System.ComponentModel.DataAnnotations;

namespace PharmacyChainsManagementBE.DTOs.Users
{
    public class UpdateProfileRequest
    {
        [MaxLength(100, ErrorMessage = "FullName cannot exceed 100 characters.")]
        [RegularExpression(@"^[^<>]*$", ErrorMessage = "HTML tags are not allowed in FullName.")]
        public string? FullName { get; set; }

        [MaxLength(500, ErrorMessage = "ProfilePhotoUri cannot exceed 500 characters.")]
        [Url(ErrorMessage = "ProfilePhotoUri must be a valid URL.")]
        public string? ProfilePhotoUri { get; set; }

        [MaxLength(255, ErrorMessage = "Address cannot exceed 255 characters.")]
        [RegularExpression(@"^[^<>]*$", ErrorMessage = "HTML tags are not allowed in Address.")]
        public string? Address { get; set; }

        public DateTime? DateOfBirth { get; set; }

        [MaxLength(10, ErrorMessage = "Gender cannot exceed 10 characters.")]
        [RegularExpression(@"^[^<>]*$", ErrorMessage = "HTML tags are not allowed in Gender.")]
        public string? Gender { get; set; }

        [MaxLength(20, ErrorMessage = "PhoneNumber cannot exceed 20 characters.")]
        [RegularExpression(@"^0[0-9]{9}$", ErrorMessage = "Phone number must start with 0 and have 10 digits.")]
        public string? PhoneNumber { get; set; }
    }
}
