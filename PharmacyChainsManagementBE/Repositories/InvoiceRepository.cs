using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Repositories;

public class InvoiceRepository : IInvoiceRepository
{
    private readonly PharmacyDbContext _context;

    public InvoiceRepository(PharmacyDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Invoice>> GetPaidInvoicesAsync(Guid? branchId, DateOnly fromDate, DateOnly toDate)
    {
        var query = _context.Invoices.AsNoTracking()
            .Where(i => i.PaymentStatus == "Paid" 
                     && i.InvoiceDate >= fromDate 
                     && i.InvoiceDate <= toDate);
                     
        if (branchId.HasValue && branchId.Value != Guid.Empty)
        {
            query = query.Where(i => i.BranchId == branchId.Value);
        }

        return await query.ToListAsync();
    }
}
