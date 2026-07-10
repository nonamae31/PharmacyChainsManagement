using System.Threading;
using System.Threading.Channels;
using System.Threading.Tasks;

namespace PharmacyChainsManagementBE.Services;

public class EmailAlertQueue : IEmailAlertQueue
{
    private readonly Channel<EmailMessage> _queue;

    public EmailAlertQueue()
    {
        var options = new BoundedChannelOptions(100) { FullMode = BoundedChannelFullMode.Wait };
        _queue = Channel.CreateBounded<EmailMessage>(options);
    }

    public async ValueTask EnqueueEmailAsync(EmailMessage message, CancellationToken cancellationToken = default)
    {
        await _queue.Writer.WriteAsync(message, cancellationToken);
    }

    public async ValueTask<EmailMessage> DequeueAsync(CancellationToken cancellationToken)
    {
        return await _queue.Reader.ReadAsync(cancellationToken);
    }
}
