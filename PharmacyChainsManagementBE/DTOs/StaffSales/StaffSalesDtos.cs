using System;
using System.Collections.Generic;

namespace PharmacyChainsManagementBE.DTOs.StaffSales;

public sealed record MedicineSearchResponseDto(
    Guid MedicineId,
    string MedicineName,
    string? Category,
    string Unit,
    decimal UnitPrice,
    int AvailableQuantity,
    int SafetyStockLevel,
    string StockStatus,
    DateOnly? NearestExpiryDate);

public sealed record InvoiceLineRequestDto(Guid MedicineId, int Quantity);

public sealed record CreateInvoiceRequestDto(IReadOnlyList<InvoiceLineRequestDto> Items);

public sealed record InvoiceLineResponseDto(
    Guid InvoiceDetailId,
    Guid MedicineId,
    string MedicineName,
    Guid BatchId,
    string BatchNumber,
    int Quantity,
    decimal UnitPrice,
    decimal LineTotal);

public sealed record InvoiceResponseDto(
    Guid InvoiceId,
    string InvoiceCode,
    DateOnly InvoiceDate,
    decimal TotalAmount,
    string PaymentStatus,
    string Status,
    IReadOnlyList<InvoiceLineResponseDto> Items);

public sealed record InvoiceListItemResponseDto(
    Guid InvoiceId,
    string InvoiceCode,
    DateOnly InvoiceDate,
    decimal TotalAmount,
    string PaymentStatus,
    string Status,
    int ItemCount);

public sealed record CreatePaymentRequestDto(string PaymentMethod);

public sealed record PaymentTransactionResponseDto(
    Guid PaymentId,
    Guid InvoiceId,
    string InvoiceCode,
    decimal Amount,
    decimal? ExchangeRate,
    decimal? ExpectedAmountVnd,
    decimal? ReceivedAmountVnd,
    string BaseCurrency,
    string SettlementCurrency,
    string PaymentMethod,
    string PaymentStatus,
    DateTime? PaymentDate,
    string? GatewayReference,
    string? QrCodeUrl,
    string? BankName,
    string? AccountName,
    string? AccountNumber,
    string? TransferContent,
    DateTime? ExpiresAt);

public sealed record StaffDashboardResponseDto(
    decimal TodayRevenue,
    int TodayInvoiceCount,
    int PendingInvoiceCount,
    int LowStockItemCount,
    string ShiftLabel);
