using System;

namespace PharmacyChainsManagementBE.Features.Finance;

public class CashFlowDto
{
    public decimal TotalInflow { get; set; }
    public decimal TotalOutflow { get; set; }
    public decimal NetCashFlow { get; set; }
}
