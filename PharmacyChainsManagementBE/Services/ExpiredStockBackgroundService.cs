using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Services;

public class ExpiredStockBackgroundService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<ExpiredStockBackgroundService> _logger;

    public ExpiredStockBackgroundService(IServiceProvider serviceProvider, ILogger<ExpiredStockBackgroundService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("ExpiredStockBackgroundService is starting.");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessExpiredStockAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred executing ExpiredStockBackgroundService.");
            }

            // Calculate time until next midnight
            var now = DateTime.Now;
            var nextMidnight = now.Date.AddDays(1);
            var delay = nextMidnight - now;
            
            // Wait until next midnight
            await Task.Delay(delay, stoppingToken);
        }
    }

    private async Task ProcessExpiredStockAsync(CancellationToken stoppingToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<PharmacyDbContext>();
        var auditLogService = scope.ServiceProvider.GetRequiredService<IAuditLogService>();

        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        // Find all batches that are past their expiry date and not yet marked as EXPIRED
        var expiredBatches = await dbContext.MedicineBatches
            .Where(b => b.ExpiryDate < today && b.Status != "EXPIRED" && b.Status != "DISPOSED")
            .ToListAsync(stoppingToken);

        if (expiredBatches.Any())
        {
            _logger.LogInformation($"Found {expiredBatches.Count} newly expired batches.");

            foreach (var batch in expiredBatches)
            {
                batch.Status = "EXPIRED";
                batch.UpdatedAt = DateTime.UtcNow;

                await auditLogService.LogAsync(
                    "AutoExpireBatch", 
                    $"Batch {batch.BatchNumber} auto-expired by system.", 
                    Guid.Empty.ToString(), // System actor
                    null, 
                    stoppingToken);
            }

            await dbContext.SaveChangesAsync(stoppingToken);
            _logger.LogInformation("Successfully updated expired batches.");
        }
    }
}
