using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.DTOs.Finance;

namespace PharmacyChainsManagementBE.Services;

public interface IFinancialReportService
{
    Task<(Stream FileStream, string ContentType, string FileName)> GenerateReportAsync(ExportCriteriaDTO criteriaDto, Guid actorId, CancellationToken cancellationToken = default);
}
