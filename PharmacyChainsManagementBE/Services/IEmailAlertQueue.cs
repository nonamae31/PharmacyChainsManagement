using System.Threading;
using System.Threading.Tasks;

namespace PharmacyChainsManagementBE.Services;

public record EmailMessage(string To, string Subject, string Body);

public interface IEmailAlertQueue
{
    ValueTask EnqueueEmailAsync(EmailMessage message, CancellationToken cancellationToken = default);
    ValueTask<EmailMessage> DequeueAsync(CancellationToken cancellationToken);
}
