using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PharmacyChainsManagementBE.DTOs.StaffSales;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Controllers;

[ApiController]
[Route("api/v1/staff-sales")]
[Authorize(Roles = "Staff")]
public sealed class StaffSalesController : ControllerBase
{
    private readonly IStaffSalesService _service;
    public StaffSalesController(IStaffSalesService service) => _service = service;

    [HttpGet("medicines")]
    public Task<IReadOnlyList<MedicineSearchResponseDto>> SearchMedicines([FromQuery] string? search, [FromQuery] string? category, [FromQuery] string? availability, CancellationToken cancellationToken) => _service.SearchMedicinesAsync(GetStaffId(), search, category, availability, cancellationToken);

    [HttpPost("invoices")]
    public Task<InvoiceResponseDto> CreateInvoice([FromBody] CreateInvoiceRequestDto request, CancellationToken cancellationToken) => _service.CreateInvoiceAsync(GetStaffId(), request, cancellationToken);

    [HttpGet("invoices")]
    public Task<IReadOnlyList<InvoiceListItemResponseDto>> GetInvoices([FromQuery] string? search, [FromQuery] string? paymentStatus, [FromQuery] DateOnly? fromDate, [FromQuery] DateOnly? toDate, CancellationToken cancellationToken) => _service.GetInvoicesAsync(GetStaffId(), search, paymentStatus, fromDate, toDate, cancellationToken);

    [HttpGet("invoices/{invoiceId:guid}")]
    public Task<InvoiceResponseDto> GetInvoice(Guid invoiceId, CancellationToken cancellationToken) => _service.GetInvoiceAsync(GetStaffId(), invoiceId, cancellationToken);

    [HttpPost("invoices/{invoiceId:guid}/payments")]
    public Task<PaymentTransactionResponseDto> CreatePayment(Guid invoiceId, [FromBody] CreatePaymentRequestDto request, CancellationToken cancellationToken) => _service.CreateMockPaymentAsync(GetStaffId(), invoiceId, request, cancellationToken);

    [HttpGet("payments")]
    public Task<IReadOnlyList<PaymentTransactionResponseDto>> GetPayments([FromQuery] string? paymentStatus, CancellationToken cancellationToken) => _service.GetPaymentsAsync(GetStaffId(), paymentStatus, cancellationToken);

    [HttpGet("dashboard")]
    public Task<StaffDashboardResponseDto> GetDashboard(CancellationToken cancellationToken) => _service.GetDashboardAsync(GetStaffId(), cancellationToken);

    private Guid GetStaffId() => Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? throw new UnauthorizedAccessException());
}
