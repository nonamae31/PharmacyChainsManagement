using FluentValidation;

namespace PharmacyChainsManagementBE.DTOs
{
    public class UpdateBusinessAdminRequestValidator : AbstractValidator<UpdateBusinessAdminRequest>
    {
        public UpdateBusinessAdminRequestValidator()
        {
            RuleFor(x => x.FullName)
                .NotEmpty().WithMessage("FullName is required.")
                .MaximumLength(150).WithMessage("FullName cannot exceed 150 characters.");

            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email is required.")
                .EmailAddress().WithMessage("Email must be in valid format.");

            RuleFor(x => x.Phone)
                .NotEmpty().WithMessage("Phone is required.")
                .Matches(@"^\+?[0-9]{10,15}$").WithMessage("Phone must be in valid format.");
        }
    }
}
