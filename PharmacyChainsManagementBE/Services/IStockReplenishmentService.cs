using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs;

namespace PharmacyChainsManagementBE.Services;

public interface IStockReplenishmentService
{
    Task<IReadOnlyList<StockReplenishmentOptionDto>> GetOptionsAsync(
        Guid branchId,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<StockReplenishmentRequestDto>> GetBranchRequestsAsync(
        Guid branchId,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<StockReplenishmentRequestDto>> GetInventoryQueueAsync(
        string? status,
        CancellationToken cancellationToken);

    Task<Result<StockReplenishmentRequestDto>> CreateAsync(
        Guid managerId,
        Guid branchId,
        CreateStockReplenishmentRequestDto request,
        CancellationToken cancellationToken);

    Task<Result<StockReplenishmentRequestDto>> UpdateStatusAsync(
        Guid requestId,
        Guid inventoryManagerId,
        UpdateStockReplenishmentStatusDto request,
        CancellationToken cancellationToken);

    Task<Result<IReadOnlyList<StockReplenishmentSourceDto>>> GetDispatchSourcesAsync(
        Guid requestId,
        CancellationToken cancellationToken);

    Task<Result<StockReplenishmentRequestDto>> DispatchAsync(
        Guid requestId,
        Guid inventoryManagerId,
        DispatchStockReplenishmentDto request,
        CancellationToken cancellationToken);

}
