using System;
using System.Linq;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Controllers;

[ApiController]
[Route("api/v1/inventory")]
[Authorize]
public class InventoryController : BaseApiController
{
    private readonly IInventoryService _inventoryService;

    public InventoryController(IInventoryService inventoryService)
    {
        _inventoryService = inventoryService;
    }

    private Guid GetCurrentUserId()
    {
        var userIdString = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
        return Guid.TryParse(userIdString, out Guid userId) ? userId : Guid.Empty;
    }

    [HttpPost("receive-goods")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ReceiveGoods([FromBody] ReceiveGoodsRequest request, CancellationToken cancellationToken)
    {
        var result = await _inventoryService.ReceiveGoodsAsync(request, GetCurrentUserId(), cancellationToken);
        if (result.IsFailure) return BadRequest(ApiResponse<object>.ErrorResponse(result.Error.Message));
        return Ok(ApiResponse<object>.Ok(null, "Goods received successfully. Status is PENDING_QC."));
    }

    [HttpPost("qc-inspection")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> QCInspect([FromBody] QCInspectionRequest request, CancellationToken cancellationToken)
    {
        var result = await _inventoryService.QCInspectAsync(request, GetCurrentUserId(), cancellationToken);
        if (result.IsFailure) return BadRequest(ApiResponse<object>.ErrorResponse(result.Error.Message));
        return Ok(ApiResponse<object>.Ok(null, "QC Inspection completed successfully."));
    }

    [HttpPost("issue-stock")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> IssueStock([FromBody] IssueStockRequest request, CancellationToken cancellationToken)
    {
        var result = await _inventoryService.IssueStockAsync(request, GetCurrentUserId(), cancellationToken);
        if (result.IsFailure) return BadRequest(ApiResponse<object>.ErrorResponse(result.Error.Message));
        return Ok(ApiResponse<object>.Ok(null, "Stock issued successfully using FEFO."));
    }

    [HttpPost("approve-transfer")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ApproveTransfer([FromBody] ApproveTransferRequest request, CancellationToken cancellationToken)
    {
        var result = await _inventoryService.ApproveTransferAsync(request, GetCurrentUserId(), cancellationToken);
        if (result.IsFailure) return BadRequest(ApiResponse<object>.ErrorResponse(result.Error.Message));
        return Ok(ApiResponse<object>.Ok(null, $"Transfer {request.ApprovalStatus.ToLower()} successfully."));
    }

    [HttpPost("stocktake")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SubmitStocktake([FromBody] StocktakeRequest request, CancellationToken cancellationToken)
    {
        var result = await _inventoryService.SubmitStocktakeAsync(request, GetCurrentUserId(), cancellationToken);
        if (result.IsFailure) return BadRequest(ApiResponse<object>.ErrorResponse(result.Error.Message));
        return Ok(ApiResponse<object>.Ok(null, "Stocktake submitted and inventory adjusted successfully."));
    }

    [HttpPost("recall-batch")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> RecallBatch([FromBody] RecallBatchRequest request, CancellationToken cancellationToken)
    {
        var result = await _inventoryService.RecallBatchAsync(request, GetCurrentUserId(), cancellationToken);
        if (result.IsFailure) return BadRequest(ApiResponse<object>.ErrorResponse(result.Error.Message));
        return Ok(ApiResponse<object>.Ok(null, "Batch has been recalled successfully."));
    }

    [HttpGet("batches/{batchId}/trace")]
    [ProducesResponseType(typeof(ApiResponse<BatchTraceabilityResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetBatchTraceability(Guid batchId, CancellationToken cancellationToken)
    {
        var result = await _inventoryService.GetBatchTraceabilityAsync(batchId, cancellationToken);
        if (result.IsFailure) return NotFound(ApiResponse<object>.ErrorResponse(result.Error.Message));
        return Ok(ApiResponse<BatchTraceabilityResponse>.Ok(result.Value, "Batch traceability fetched successfully."));
    }

    [HttpGet("valuation/{branchId}")]
    [ProducesResponseType(typeof(ApiResponse<InventoryValuationResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetInventoryValuation(Guid branchId, CancellationToken cancellationToken)
    {
        var result = await _inventoryService.GetInventoryValuationAsync(branchId, cancellationToken);
        if (result.IsFailure) return NotFound(ApiResponse<object>.ErrorResponse(result.Error.Message));
        return Ok(ApiResponse<InventoryValuationResponse>.Ok(result.Value, "Inventory valuation fetched successfully."));
    }
}
