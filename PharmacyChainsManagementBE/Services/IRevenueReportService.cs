using System;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.DTOs;

namespace PharmacyChainsManagementBE.Services;

public interface IRevenueReportService
{
    Task<RevenueReportResponseDto> GenerateRevenueReportAsync(RevenueReportRequestDto request, Guid generatedByUserId);
}
