using System.Threading.Tasks;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Repositories;

public interface IReportRepository
{
    Task AddAsync(Report report);
}
