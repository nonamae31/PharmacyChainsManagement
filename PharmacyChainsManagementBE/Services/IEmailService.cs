using System.Threading;
using System.Threading.Tasks;

namespace PharmacyChainsManagementBE.Services;

public interface IEmailService
{
    Task SendPasswordResetEmailAsync(string email, string token, CancellationToken cancellationToken);
    Task SendEmailAsync(string toEmail, string subject, string body, CancellationToken cancellationToken);
}
