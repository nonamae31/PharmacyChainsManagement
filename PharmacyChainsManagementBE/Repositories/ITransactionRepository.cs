using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Repositories;

public interface ITransactionRepository
{
    Task<List<PaymentTransaction>> GetCompletedTransactionsAsync(Guid branchId, DateTime startDate, DateTime endDate, CancellationToken cancellationToken = default);
}
