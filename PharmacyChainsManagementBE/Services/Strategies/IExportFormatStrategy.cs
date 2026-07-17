using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace PharmacyChainsManagementBE.Services.Strategies;

public interface IExportFormatStrategy<T>
{
    string ContentType { get; }
    string GetFileName();
    Task<Stream> GenerateAndFormatAsync(T payload, CancellationToken cancellationToken = default);
}
