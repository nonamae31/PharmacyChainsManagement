using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.DTOs.StaffSales;

namespace PharmacyChainsManagementBE.Services;

public interface IStaffSalesService
{
    Task<IReadOnlyList<MedicineSearchResponseDto>> SearchMedicinesAsync(Guid staffId, string? search, string? category, string? availability, CancellationToken cancellationToken);
    Task<InvoiceResponseDto> CreateInvoiceAsync(Guid staffId, CreateInvoiceRequestDto request, CancellationToken cancellationToken);
    Task<IReadOnlyList<InvoiceListItemResponseDto>> GetInvoicesAsync(Guid staffId, string? search, string? paymentStatus, DateOnly? fromDate, DateOnly? toDate, CancellationToken cancellationToken);
    Task<InvoiceResponseDto> GetInvoiceAsync(Guid staffId, Guid invoiceId, CancellationToken cancellationToken);
    Task<PaymentTransactionResponseDto> CreateMockPaymentAsync(Guid staffId, Guid invoiceId, CreatePaymentRequestDto request, CancellationToken cancellationToken);
    Task<PaymentTransactionResponseDto> GetPaymentAsync(Guid staffId, Guid paymentId, CancellationToken cancellationToken);
    Task<int> CancelExpiredQrInvoicesAsync(CancellationToken cancellationToken);
    Task ProcessSePayWebhookAsync(SePayWebhookRequestDto request, CancellationToken cancellationToken);
    Task<IReadOnlyList<PaymentTransactionResponseDto>> GetPaymentsAsync(Guid staffId, string? paymentStatus, CancellationToken cancellationToken);
    Task<StaffDashboardResponseDto> GetDashboardAsync(Guid staffId, CancellationToken cancellationToken);
}
