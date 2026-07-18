using System;
using System.Collections.Generic;
namespace PharmacyChainsManagementBE.Features.Finance;

public class CashFlowDto
{
    public decimal TotalInflow { get; set; }
    public decimal TotalOutflow { get; set; }
    public decimal NetCashFlow { get; set; }

    public List<RecentTransactionDto> RecentTransactions { get; set; } = new();
    public List<LiquidityForecastDto> LiquidityForecasts { get; set; } = new();
    public List<BudgetAllocationDto> BudgetAllocations { get; set; } = new();
    public List<CashFlowDailyDataDto> DailyData { get; set; } = new();
}

public class CashFlowDailyDataDto
{
    public DateTime Date { get; set; }
    public decimal Inflow { get; set; }
    public decimal Outflow { get; set; }
}

public class RecentTransactionDto
{
    public Guid Id { get; set; }
    public DateTime Date { get; set; }
    public string Description { get; set; }
    public decimal Amount { get; set; }
    public string Type { get; set; } // "Inflow" or "Outflow"
}

public class LiquidityForecastDto
{
    public string Month { get; set; } // e.g., "Jan", "Feb"
    public decimal ProjectedInflow { get; set; }
    public decimal ProjectedOutflow { get; set; }
}

public class BudgetAllocationDto
{
    public string CategoryName { get; set; }
    public decimal Percentage { get; set; }
}
