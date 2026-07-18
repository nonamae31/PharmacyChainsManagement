using System;
using System.Data;
using System.Threading;
using System.Threading.Tasks;
using Dapper;
using MediatR;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Features.Finance;

public class GetCashFlowQueryHandler : IRequestHandler<GetCashFlowQuery, CashFlowDto>
{
    private readonly PharmacyDbContext _context;

    public GetCashFlowQueryHandler(PharmacyDbContext context)
    {
        _context = context;
    }

    public async Task<CashFlowDto> Handle(GetCashFlowQuery request, CancellationToken cancellationToken)
    {
        var connection = _context.Database.GetDbConnection();
        if (connection.State != ConnectionState.Open)
        {
            await connection.OpenAsync(cancellationToken);
        }
        
        try
        {
        string inflowSql = @"
            SELECT COALESCE(SUM(pt.amount), 0)
            FROM ""PAYMENT_TRANSACTION"" pt
            LEFT JOIN ""INVOICE"" i ON pt.invoice_id = i.invoice_id
            WHERE pt.payment_status = 'Paid'
              AND pt.payment_date >= CAST(@StartDate AS timestamp)
              AND pt.payment_date <= CAST(@EndDate AS timestamp)
        ";
        
        var startDateParam = request.StartDate.ToDateTime(TimeOnly.MinValue);
        var endDateParam = request.EndDate.ToDateTime(TimeOnly.MaxValue);
        
        if (request.BranchId.HasValue)
        {
            inflowSql += " AND i.branch_id = @BranchId";
        }
        
        string outflowSql = @"
            SELECT COALESCE(SUM(pod.line_total), 0)
            FROM ""PURCHASE_ORDER_DETAIL"" pod
            INNER JOIN ""PURCHASE_ORDER"" po ON pod.po_id = po.po_id
            WHERE po.po_status IN ('Completed', 'Approved')
              AND po.order_date >= CAST(@StartDate AS date)
              AND po.order_date <= CAST(@EndDate AS date)
        ";
        
        if (request.BranchId.HasValue)
        {
            outflowSql += " AND po.branch_id = @BranchId";
        }
        
        var parameters = new { 
            StartDate = startDateParam, 
            EndDate = endDateParam, 
            BranchId = request.BranchId 
        };

        string recentTransactionsSql = $@"
            SELECT * FROM (
                SELECT pt.payment_id as Id, pt.payment_date as Date, 'Inflow from Invoice ' || COALESCE(i.invoice_code, '') as Description, pt.amount as Amount, 'Inflow' as Type
                FROM ""PAYMENT_TRANSACTION"" pt
                LEFT JOIN ""INVOICE"" i ON pt.invoice_id = i.invoice_id
                WHERE pt.payment_status = 'Paid'
                  AND pt.payment_date >= CAST(@StartDate AS timestamp)
                  AND pt.payment_date <= CAST(@EndDate AS timestamp)
                  {(request.BranchId.HasValue ? " AND i.branch_id = @BranchId" : "")}
                  
                UNION ALL
                
                SELECT pod.po_detail_id as Id, CAST(po.order_date AS timestamp) as Date, 'Outflow for PO ' || po.po_id as Description, pod.line_total as Amount, 'Outflow' as Type
                FROM ""PURCHASE_ORDER_DETAIL"" pod
                INNER JOIN ""PURCHASE_ORDER"" po ON pod.po_id = po.po_id
                WHERE po.po_status IN ('Completed', 'Approved')
                  AND po.order_date >= CAST(@StartDate AS date)
                  AND po.order_date <= CAST(@EndDate AS date)
                  {(request.BranchId.HasValue ? " AND po.branch_id = @BranchId" : "")}
            ) AS RecentTransactions
            ORDER BY Date DESC
            LIMIT 5
        ";

        string budgetSql = @"
            SELECT category_name as CategoryName, percentage as Percentage
            FROM ""BUDGET_ALLOCATION""
        ";

        string forecastSql = @"
            SELECT to_char(forecast_date, 'Mon') as Month, projected_inflow as ProjectedInflow, projected_outflow as ProjectedOutflow
            FROM ""LIQUIDITY_FORECAST""
            WHERE forecast_date >= CAST(@StartDate AS date)
              AND forecast_date <= CAST(@EndDate AS date)
            ORDER BY forecast_date
        ";

        string dailySql = @"
            WITH dates AS (
                SELECT CAST(generate_series(CAST(@StartDate AS date), CAST(@EndDate AS date), '1 day'::interval) AS date) AS date
            ),
            inflows AS (
                SELECT CAST(pt.payment_date AS date) as date, SUM(pt.amount) as amount
                FROM ""PAYMENT_TRANSACTION"" pt
                LEFT JOIN ""INVOICE"" i ON pt.invoice_id = i.invoice_id
                WHERE pt.payment_status = 'Paid'
                  AND pt.payment_date >= CAST(@StartDate AS timestamp)
                  AND pt.payment_date <= CAST(@EndDate AS timestamp)
                  " + (request.BranchId.HasValue ? " AND i.branch_id = @BranchId" : "") + @"
                GROUP BY CAST(pt.payment_date AS date)
            ),
            outflows AS (
                SELECT CAST(po.order_date AS date) as date, SUM(pod.line_total) as amount
                FROM ""PURCHASE_ORDER_DETAIL"" pod
                INNER JOIN ""PURCHASE_ORDER"" po ON pod.po_id = po.po_id
                WHERE po.po_status IN ('Completed', 'Approved')
                  AND po.order_date >= CAST(@StartDate AS date)
                  AND po.order_date <= CAST(@EndDate AS date)
                  " + (request.BranchId.HasValue ? " AND po.branch_id = @BranchId" : "") + @"
                GROUP BY CAST(po.order_date AS date)
            )
            SELECT 
                CAST(d.date AS timestamp) as Date,
                COALESCE(i.amount, 0) as Inflow,
                COALESCE(o.amount, 0) as Outflow
            FROM dates d
            LEFT JOIN inflows i ON d.date = i.date
            LEFT JOIN outflows o ON d.date = o.date
            ORDER BY d.date
        ";

        var totalInflow = await connection.ExecuteScalarAsync<decimal>(inflowSql, parameters);
        var totalOutflow = await connection.ExecuteScalarAsync<decimal>(outflowSql, parameters);
        var recentTransactions = await connection.QueryAsync<RecentTransactionDto>(recentTransactionsSql, parameters);
        var budgetAllocations = await connection.QueryAsync<BudgetAllocationDto>(budgetSql);
        var liquidityForecasts = await connection.QueryAsync<LiquidityForecastDto>(forecastSql, parameters);
        var dailyData = await connection.QueryAsync<CashFlowDailyDataDto>(dailySql, parameters);

        return new CashFlowDto
        {
            TotalInflow = totalInflow,
            TotalOutflow = totalOutflow,
            NetCashFlow = totalInflow - totalOutflow,
            RecentTransactions = recentTransactions.AsList(),
            BudgetAllocations = budgetAllocations.AsList(),
            LiquidityForecasts = liquidityForecasts.AsList(),
            DailyData = dailyData.AsList()
        };
        }
        finally
        {
            if (connection.State == ConnectionState.Open)
            {
                await connection.CloseAsync();
            }
        }
    }
}
