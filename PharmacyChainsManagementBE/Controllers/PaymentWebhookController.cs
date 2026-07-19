using System;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using PharmacyChainsManagementBE.Common.Settings;
using PharmacyChainsManagementBE.DTOs.StaffSales;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Controllers;

[ApiController]
[Route("api/v1/payment-webhooks")]
[AllowAnonymous]
public sealed class PaymentWebhookController : ControllerBase
{
    private readonly IStaffSalesService _staffSalesService;
    private readonly SePayWebhookSettings _settings;

    public PaymentWebhookController(
        IStaffSalesService staffSalesService,
        IOptions<SePayWebhookSettings> settings)
    {
        _staffSalesService = staffSalesService;
        _settings = settings.Value;
    }

    [HttpPost("sepay")]
    public async Task<ActionResult<SePayWebhookResponseDto>> ReceiveSePayWebhook(
        [FromBody] SePayWebhookRequestDto request,
        CancellationToken cancellationToken)
    {
        if (!IsAuthorized(Request.Headers.Authorization.ToString()))
        {
            return Unauthorized(new SePayWebhookResponseDto(false));
        }

        await _staffSalesService.ProcessSePayWebhookAsync(request, cancellationToken);
        return Ok(new SePayWebhookResponseDto(true));
    }

    private bool IsAuthorized(string authorization)
    {
        if (string.IsNullOrWhiteSpace(_settings.ApiKey))
        {
            return false;
        }

        const string prefix = "Apikey ";
        if (!authorization.StartsWith(prefix, StringComparison.Ordinal))
        {
            return false;
        }

        var receivedBytes = Encoding.UTF8.GetBytes(authorization[prefix.Length..]);
        var expectedBytes = Encoding.UTF8.GetBytes(_settings.ApiKey);
        return receivedBytes.Length == expectedBytes.Length
            && CryptographicOperations.FixedTimeEquals(receivedBytes, expectedBytes);
    }
}
