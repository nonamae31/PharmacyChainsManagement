using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using PharmacyChainsManagementBE.Common.Exceptions;
using PharmacyChainsManagementBE.DTOs.Finance;
using PharmacyChainsManagementBE.Repositories;
using PharmacyChainsManagementBE.Services.Strategies;

namespace PharmacyChainsManagementBE.Services;

public class FinancialReportService : IFinancialReportService
{
    private readonly ITransactionRepository _transactionRepository;
    private readonly IAuditLogRepository _auditLogRepository;
    private readonly IEnumerable<IExportFormatStrategy<ReportPayloadDTO>> _strategies;
    private readonly ILogger<FinancialReportService> _logger;

    public FinancialReportService(
        ITransactionRepository transactionRepository,
        IAuditLogRepository auditLogRepository,
        IEnumerable<IExportFormatStrategy<ReportPayloadDTO>> strategies,
        ILogger<FinancialReportService> logger)
    {
        _transactionRepository = transactionRepository;
        _auditLogRepository = auditLogRepository;
        _strategies = strategies;
        _logger = logger;
    }

    public async Task<(Stream FileStream, string ContentType, string FileName)> GenerateReportAsync(ExportCriteriaDTO criteriaDto, Guid actorId, CancellationToken cancellationToken = default)
    {
        try
        {
            var transactions = await _transactionRepository.GetCompletedTransactionsAsync(
                criteriaDto.BranchId,
                criteriaDto.StartDate,
                criteriaDto.EndDate,
                cancellationToken);

            // Allow empty transactions because the report can still contain total revenue data.
            // if (transactions == null || transactions.Count == 0)
            // {
            //     _logger.LogWarning("No transactions found for Branch {BranchId} from {StartDate} to {EndDate}", 
            //         criteriaDto.BranchId, criteriaDto.StartDate, criteriaDto.EndDate);
            //     throw new DataNotFoundException("Data not found");
            // }

            var payload = new ReportPayloadDTO
            {
                BranchId = criteriaDto.BranchId,
                StartDate = criteriaDto.StartDate,
                EndDate = criteriaDto.EndDate,
                TotalRevenue = transactions.Sum(t => t.Amount),
                TotalTransactions = transactions.Count,
                Transactions = transactions.Select(t => new TransactionDetailDTO
                {
                    PaymentId = t.PaymentId,
                    InvoiceId = t.InvoiceId,
                    Amount = t.Amount,
                    PaymentMethod = t.PaymentMethod ?? string.Empty,
                    PaymentStatus = t.PaymentStatus ?? string.Empty,
                    PaymentDate = t.PaymentDate
                }).ToList()
            };

            var strategy = GetExportStrategy(criteriaDto.Format);
            var stream = await strategy.GenerateAndFormatAsync(payload, cancellationToken);

            await _auditLogRepository.LogExportEventAsync(
                actorId,
                "Transaction",
                criteriaDto.BranchId,
                $"EXPORT_{criteriaDto.Format}",
                null,
                $"Exported report for {criteriaDto.StartDate:yyyy-MM-dd} to {criteriaDto.EndDate:yyyy-MM-dd}",
                cancellationToken);

            _logger.LogInformation("Financial report generated successfully for Branch {BranchId} by user {ActorId}", criteriaDto.BranchId, actorId);

            return (stream, strategy.ContentType, strategy.GetFileName());
        }
        catch (DataNotFoundException)
        {
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to generate financial report for Branch {BranchId}", criteriaDto.BranchId);
            throw new GenerationException("Failed to generate financial report", ex);
        }
    }

    private IExportFormatStrategy<ReportPayloadDTO> GetExportStrategy(ExportFormat format)
    {
        return format switch
        {
            ExportFormat.PDF => _strategies.FirstOrDefault(s => s.ContentType == "application/pdf") ?? throw new InvalidOperationException("PDF strategy not registered"),
            ExportFormat.EXCEL => _strategies.FirstOrDefault(s => s.ContentType.Contains("spreadsheetml")) ?? throw new InvalidOperationException("Excel strategy not registered"),
            ExportFormat.CSV => _strategies.FirstOrDefault(s => s.ContentType == "text/csv") ?? throw new InvalidOperationException("CSV strategy not registered"),
            _ => throw new NotSupportedException($"Format {format} is not supported")
        };
    }
}
