using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace PharmacyChainsManagementBE.Services;

public class EmailService : IEmailService
{
    private readonly ILogger<EmailService> _logger;

    public EmailService(ILogger<EmailService> logger)
    {
        _logger = logger;
    }

    public Task SendPasswordResetEmailAsync(string email, string token, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        // Mock email sending by writing to logger and console
        _logger.LogInformation("Sending password reset email to {Email} with plain token: {Token}", email, token);
        Console.WriteLine($"[EMAIL SERVICE MOCK] Send to: {email} | Reset Token: {token}");
        
        return Task.CompletedTask;
    }
}
