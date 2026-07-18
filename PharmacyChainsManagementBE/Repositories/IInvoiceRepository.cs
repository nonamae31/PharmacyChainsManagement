using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Repositories;

public interface IInvoiceRepository
{
    Task<IEnumerable<Invoice>> GetPaidInvoicesAsync(Guid? branchId, DateOnly fromDate, DateOnly toDate);
}
