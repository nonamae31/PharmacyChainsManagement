using System;
using System.ComponentModel.DataAnnotations;
using FluentValidation;

using System.Text.Json.Serialization;

namespace PharmacyChainsManagementBE.DTOs.Finance;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum ExportFormat
{
    PDF,
    EXCEL,
    CSV
}

public record ExportCriteriaDTO
{
    public Guid BranchId { get; init; }
    public DateTime StartDate { get; init; }
    public DateTime EndDate { get; init; }
    public ExportFormat Format { get; init; }
}

public class ExportCriteriaDTOValidator : AbstractValidator<ExportCriteriaDTO>
{
    public ExportCriteriaDTOValidator()
    {
        RuleFor(x => x.BranchId)
            .NotNull().WithMessage("BranchId cannot be null.");

        RuleFor(x => x.StartDate)
            .NotEmpty().WithMessage("StartDate is required.");

        RuleFor(x => x.EndDate)
            .NotEmpty().WithMessage("EndDate is required.")
            .GreaterThanOrEqualTo(x => x.StartDate).WithMessage("EndDate must be greater than or equal to StartDate.");

        RuleFor(x => x)
            .Must(x => (x.EndDate - x.StartDate).TotalDays <= 31)
            .WithMessage("Date range cannot exceed 31 days.")
            .When(x => x.StartDate != default && x.EndDate != default);
            
        RuleFor(x => x.Format)
            .IsInEnum().WithMessage("Invalid export format.");
    }
}
