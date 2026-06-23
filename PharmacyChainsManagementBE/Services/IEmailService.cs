using System.Threading;
using System.Threading.Tasks;

namespace PharmacyChainsManagementBE.Services;

public interface IEmailService
{
    Task SendPasswordResetEmailAsync(string email, string token, CancellationToken cancellationToken);
}
