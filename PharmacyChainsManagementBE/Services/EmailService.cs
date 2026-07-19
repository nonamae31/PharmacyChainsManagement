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

    public async Task SendPasswordResetEmailAsync(string email, string token, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();

        _logger.LogInformation("Sending password reset email to {Email} with OTP token: {Token}", email, token);
        Console.WriteLine($"\n=======================================================");
        Console.WriteLine($"[EMAIL SERVICE - OTP verification code]");
        Console.WriteLine($"To Email : {email}");
        Console.WriteLine($"OTP Code : {token}");
        Console.WriteLine($"=======================================================\n");

        var subject = "[Pharmacy Chains Management] Mã xác nhận đặt lại mật khẩu (OTP)";
        var body = $@"Xin chào,

Bạn vừa yêu cầu khôi phục mật khẩu cho tài khoản ({email}) trên hệ thống Pharmacy Chains Management.

Mã xác nhận (OTP) của bạn là: {token}

Mã này có hiệu lực trong vòng 15 phút. Vui lòng tuyệt đối không chia sẻ mã này cho bất kỳ ai để bảo vệ an toàn cho tài khoản của bạn.

Nếu bạn không yêu cầu khôi phục mật khẩu, xin vui lòng bỏ qua email này.

Trân trọng,
Hệ thống Quản lý Chuỗi Nhà thuốc GSP (Pharmacy Chains Management System)";

        await SendEmailAsync(email, subject, body, cancellationToken);
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
