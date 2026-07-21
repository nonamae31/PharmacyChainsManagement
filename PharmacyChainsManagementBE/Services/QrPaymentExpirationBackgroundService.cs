using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace PharmacyChainsManagementBE.Services;

public sealed class QrPaymentExpirationBackgroundService : BackgroundService
{
    private static readonly TimeSpan CheckInterval = TimeSpan.FromSeconds(30);

    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<QrPaymentExpirationBackgroundService> _logger;

    public QrPaymentExpirationBackgroundService(
        IServiceProvider serviceProvider,
        ILogger<QrPaymentExpirationBackgroundService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("QR payment expiration service is starting.");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var staffSalesService =
                    scope.ServiceProvider.GetRequiredService<IStaffSalesService>();
                var cancelledCount = await staffSalesService
                    .CancelExpiredQrInvoicesAsync(stoppingToken);

                if (cancelledCount > 0)
                {
                    _logger.LogInformation(
                        "Cancelled {InvoiceCount} expired unpaid invoices.",
                        cancelledCount);
                }
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception exception)
            {
                _logger.LogError(
                    exception,
                    "Error while cancelling expired unpaid invoices.");
            }

            await Task.Delay(CheckInterval, stoppingToken);
        }
    }
}
