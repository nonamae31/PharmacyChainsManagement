using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.DependencyInjection;

namespace PharmacyChainsManagementBE.Services;

public class SuspiciousLoginAlertBackgroundService : BackgroundService
{
    private readonly IEmailAlertQueue _queue;
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<SuspiciousLoginAlertBackgroundService> _logger;

    public SuspiciousLoginAlertBackgroundService(IEmailAlertQueue queue, IServiceProvider serviceProvider, ILogger<SuspiciousLoginAlertBackgroundService> logger)
    {
        _queue = queue;
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("SuspiciousLoginAlertBackgroundService is starting.");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                var message = await _queue.DequeueAsync(stoppingToken);

                using var scope = _serviceProvider.CreateScope();
                _logger.LogWarning("ALERT SENT: Email to {To}, Subject: {Subject}, Body: {Body}", message.To, message.Subject, message.Body);
                await Task.Delay(500, stoppingToken);
            }
            catch (OperationCanceledException)
            {
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred executing EmailAlertQueue.");
            }
        }
    }
}
