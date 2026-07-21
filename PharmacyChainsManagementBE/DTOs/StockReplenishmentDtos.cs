using System.ComponentModel.DataAnnotations;

namespace PharmacyChainsManagementBE.DTOs;

public sealed class CreateStockReplenishmentRequestDto
{
    [Required, RegularExpression("^(NORMAL|URGENT)$")]
    public string Priority { get; init; } = "NORMAL";

    [StringLength(500)]
    public string? Notes { get; init; }

    [Required, MinLength(1), MaxLength(50)]
    public IReadOnlyList<CreateStockReplenishmentItemDto> Items { get; init; } =
        Array.Empty<CreateStockReplenishmentItemDto>();
}

public sealed class CreateStockReplenishmentItemDto
{
    [Required]
    public Guid MedicineId { get; init; }

    [Range(1, 100000)]
    public int Quantity { get; init; }
}

public sealed class UpdateStockReplenishmentStatusDto
{
    [Required, RegularExpression("^(PROCESSING|REJECTED)$")]
    public string Status { get; init; } = string.Empty;

    [StringLength(500)]
    public string? InventoryNote { get; init; }
}

public sealed class DispatchStockReplenishmentDto
{
    [Required]
    public Guid SourceBranchId { get; init; }

    [StringLength(500)]
    public string? InventoryNote { get; init; }
}

public sealed record StockReplenishmentSourceDto(
    Guid BranchId,
    string BranchName);

public sealed record StockReplenishmentOptionDto(
    Guid MedicineId,
    string MedicineName,
    string Category,
    string Unit,
    int CurrentStock,
    int ReorderPoint);

public sealed record StockReplenishmentItemDto(
    Guid MedicineId,
    string MedicineName,
    string Unit,
    int RequestedQuantity);

public sealed record StockReplenishmentRequestDto(
    Guid RequestId,
    string RequestNo,
    Guid BranchId,
    string BranchName,
    Guid RequestedBy,
    string RequestedByName,
    string Priority,
    string Status,
    string? Notes,
    string? InventoryNote,
    DateOnly RequestDate,
    DateTime? ProcessedAt,
    Guid? TransferId,
    string? SourceBranchName,
    DateTime? DispatchedAt,
    DateTime? ReceivedAt,
    DateTime CreatedAt,
    IReadOnlyList<StockReplenishmentItemDto> Items);
