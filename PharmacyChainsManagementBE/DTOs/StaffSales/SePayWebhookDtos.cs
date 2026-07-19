using System.Text.Json.Serialization;

namespace PharmacyChainsManagementBE.DTOs.StaffSales;

public sealed record SePayWebhookRequestDto(
    long Id,
    string Gateway,
    string TransactionDate,
    string AccountNumber,
    string? SubAccount,
    string? Code,
    string Content,
    string TransferType,
    decimal TransferAmount,
    decimal Accumulated,
    string? ReferenceCode);

public sealed record SePayWebhookResponseDto(
    [property: JsonPropertyName("success")] bool Success);
