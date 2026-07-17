using System.Threading.Tasks;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Repositories;

public class ReportRepository : IReportRepository
{
    private readonly PharmacyDbContext _context;

    public ReportRepository(PharmacyDbContext context)
    {
        _context = context;
    }

    public async Task AddAsync(Report report)
    {
        await _context.Reports.AddAsync(report);
    }
}
