using FluentValidation;
using System;

namespace PharmacyChainsManagementBE.DTOs.Users
{
    public class UpdateProfileRequestValidator : AbstractValidator<UpdateProfileRequest>
    {
        public UpdateProfileRequestValidator()
        {
            RuleFor(x => x.FullName)
                .MaximumLength(100).WithMessage("Full name cannot exceed 100 characters.")
                .When(x => !string.IsNullOrEmpty(x.FullName));

            RuleFor(x => x.ProfilePhotoUri)
                .Must(uri => Uri.TryCreate(uri, UriKind.Absolute, out _))
                .When(x => !string.IsNullOrEmpty(x.ProfilePhotoUri))
                .WithMessage("Profile photo URI must be a valid absolute URI.");
        }
    }
}
