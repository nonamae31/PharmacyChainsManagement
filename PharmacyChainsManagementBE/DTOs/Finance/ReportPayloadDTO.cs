using System;
using System.Collections.Generic;

namespace PharmacyChainsManagementBE.DTOs.Finance;

public record ReportPayloadDTO
{
    public Guid BranchId { get; init; }
    public DateTime StartDate { get; init; }
    public DateTime EndDate { get; init; }
    public decimal TotalRevenue { get; init; }
    public int TotalTransactions { get; init; }
    public List<TransactionDetailDTO> Transactions { get; init; } = new();
}

public record TransactionDetailDTO
{
    public Guid PaymentId { get; init; }
    public Guid InvoiceId { get; init; }
    public decimal Amount { get; init; }
    public string PaymentMethod { get; init; } = string.Empty;
    public string PaymentStatus { get; init; } = string.Empty;
    public DateTime? PaymentDate { get; init; }
}
