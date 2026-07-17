using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace PharmacyChainsManagementBE.Services;

public class EmailService : IEmailService
{
    private readonly ILogger<EmailService> _logger;
    private readonly Microsoft.Extensions.Configuration.IConfiguration _configuration;

    public EmailService(ILogger<EmailService> logger, Microsoft.Extensions.Configuration.IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    public Task SendPasswordResetEmailAsync(string email, string token, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        // Mock email sending by writing to logger and console
        _logger.LogInformation("Sending password reset email to {Email} with plain token: {Token}", email, token);
        Console.WriteLine($"[EMAIL SERVICE MOCK] Send to: {email} | Reset Token: {token}");
        
        return Task.CompletedTask;
    }

    public async Task SendEmailAsync(string toEmail, string subject, string body, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        
        var smtpSettings = _configuration.GetSection("SmtpSettings").Get<PharmacyChainsManagementBE.Models.SmtpSettings>();
        if (smtpSettings == null || string.IsNullOrEmpty(smtpSettings.Host))
        {
            _logger.LogWarning("SmtpSettings is missing. Cannot send real email to {ToEmail}", toEmail);
            return;
        }

        try
        {
            using var client = new System.Net.Mail.SmtpClient(smtpSettings.Host, smtpSettings.Port)
            {
                Credentials = new System.Net.NetworkCredential(smtpSettings.Username, smtpSettings.Password),
                EnableSsl = smtpSettings.EnableSsl
            };

            var mailMessage = new System.Net.Mail.MailMessage
            {
                From = new System.Net.Mail.MailAddress(smtpSettings.Username, smtpSettings.SenderName),
                Subject = subject,
                Body = body,
                IsBodyHtml = false,
            };
            mailMessage.To.Add(toEmail);

            await client.SendMailAsync(mailMessage, cancellationToken);
            _logger.LogInformation("Real email sent successfully to {ToEmail} with subject {Subject}", toEmail, subject);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send real email to {ToEmail}", toEmail);
        }
    }
}
