using System;
using System.ComponentModel.DataAnnotations;
using FluentValidation;

namespace PharmacyChainsManagementBE.DTOs;

public class RevenueReportRequestDto
{
    public Guid BranchId { get; set; }

    [Required]
    public DateOnly FromDate { get; set; }

    [Required]
    public DateOnly ToDate { get; set; }
}

public class RevenueReportRequestDtoValidator : AbstractValidator<RevenueReportRequestDto>
{
    public RevenueReportRequestDtoValidator()
    {
        RuleFor(x => x.FromDate)
            .LessThanOrEqualTo(x => x.ToDate)
            .WithMessage("FromDate must be less than or equal to ToDate.");
    }
}
