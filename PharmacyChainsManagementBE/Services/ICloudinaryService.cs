using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace PharmacyChainsManagementBE.Services
{
    public interface ICloudinaryService
    {
        Task<string?> UploadImageAsync(IFormFile file);
    }
}
