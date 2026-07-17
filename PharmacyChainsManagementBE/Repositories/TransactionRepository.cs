using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Repositories;

public class TransactionRepository : ITransactionRepository
{
    private readonly PharmacyDbContext _context;

    public TransactionRepository(PharmacyDbContext context)
    {
        _context = context;
    }

    public async Task<List<PaymentTransaction>> GetCompletedTransactionsAsync(Guid branchId, DateTime startDate, DateTime endDate, CancellationToken cancellationToken = default)
    {
        return await _context.PaymentTransactions
            .AsNoTracking() // Enhancement E1: Use .AsNoTracking() for performance
            .Include(t => t.Invoice)
            .Where(t => t.Invoice.BranchId == branchId 
                        && t.PaymentStatus == "Completed" 
                        && t.PaymentDate >= startDate 
                        && t.PaymentDate <= endDate)
            .ToListAsync(cancellationToken);
    }
}
