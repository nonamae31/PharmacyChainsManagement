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
        using var connection = _context.Database.GetDbConnection();
        
        string inflowSql = @"
            SELECT ISNULL(SUM(pt.amount), 0)
            FROM PAYMENT_TRANSACTION pt
            LEFT JOIN INVOICE i ON pt.invoice_id = i.invoice_id
            WHERE pt.payment_status = 'Paid'
              AND pt.payment_date >= @StartDate 
              AND pt.payment_date <= @EndDate
        ";
        
        var startDateParam = request.StartDate.ToDateTime(TimeOnly.MinValue);
        var endDateParam = request.EndDate.ToDateTime(TimeOnly.MaxValue);
        
        if (request.BranchId.HasValue)
        {
            inflowSql += " AND i.branch_id = @BranchId";
        }
        
        string outflowSql = @"
            SELECT ISNULL(SUM(pod.line_total), 0)
            FROM PURCHASE_ORDER_DETAIL pod
            INNER JOIN PURCHASE_ORDER po ON pod.po_id = po.po_id
            WHERE po.po_status IN ('Completed', 'Approved')
              AND po.order_date >= @StartDate 
              AND po.order_date <= @EndDate
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

        var inflowTask = connection.ExecuteScalarAsync<decimal>(inflowSql, parameters);
        var outflowTask = connection.ExecuteScalarAsync<decimal>(outflowSql, parameters);

        await Task.WhenAll(inflowTask, outflowTask);

        var totalInflow = inflowTask.Result;
        var totalOutflow = outflowTask.Result;

        return new CashFlowDto
        {
            TotalInflow = totalInflow,
            TotalOutflow = totalOutflow,
            NetCashFlow = totalInflow - totalOutflow
        };
    }
}
