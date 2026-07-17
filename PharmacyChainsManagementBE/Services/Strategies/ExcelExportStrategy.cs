using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using ClosedXML.Excel;
using PharmacyChainsManagementBE.DTOs.Finance;

namespace PharmacyChainsManagementBE.Services.Strategies;

public class ExcelExportStrategy : IExportFormatStrategy<ReportPayloadDTO>
{
    public string ContentType => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

    public string GetFileName()
    {
        return $"financial_report_{DateTime.UtcNow:yyyyMMddHHmmss}.xlsx";
    }

    public Task<Stream> GenerateAndFormatAsync(ReportPayloadDTO payload, CancellationToken cancellationToken = default)
    {
        var workbook = new XLWorkbook();
        var worksheet = workbook.Worksheets.Add("Financial Report");

        // Header section
        worksheet.Cell(1, 1).Value = "Branch ID";
        worksheet.Cell(1, 2).Value = payload.BranchId.ToString();

        worksheet.Cell(2, 1).Value = "Start Date";
        worksheet.Cell(2, 2).Value = payload.StartDate.ToString("yyyy-MM-dd");

        worksheet.Cell(3, 1).Value = "End Date";
        worksheet.Cell(3, 2).Value = payload.EndDate.ToString("yyyy-MM-dd");

        worksheet.Cell(4, 1).Value = "Total Revenue";
        worksheet.Cell(4, 2).Value = payload.TotalRevenue;

        worksheet.Cell(5, 1).Value = "Total Transactions";
        worksheet.Cell(5, 2).Value = payload.TotalTransactions;

        // Transactions Table Header
        worksheet.Cell(7, 1).Value = "Payment ID";
        worksheet.Cell(7, 2).Value = "Invoice ID";
        worksheet.Cell(7, 3).Value = "Amount";
        worksheet.Cell(7, 4).Value = "Payment Method";
        worksheet.Cell(7, 5).Value = "Payment Status";
        worksheet.Cell(7, 6).Value = "Payment Date";

        var headerRow = worksheet.Range(7, 1, 7, 6);
        headerRow.Style.Font.Bold = true;

        // Fill Transactions
        int row = 8;
        foreach (var t in payload.Transactions)
        {
            worksheet.Cell(row, 1).Value = t.PaymentId.ToString();
            worksheet.Cell(row, 2).Value = t.InvoiceId.ToString();
            worksheet.Cell(row, 3).Value = t.Amount;
            worksheet.Cell(row, 4).Value = t.PaymentMethod;
            worksheet.Cell(row, 5).Value = t.PaymentStatus;
            worksheet.Cell(row, 6).Value = t.PaymentDate?.ToString("yyyy-MM-dd HH:mm:ss");
            row++;
        }

        worksheet.Columns().AdjustToContents();

        var memoryStream = new MemoryStream();
        workbook.SaveAs(memoryStream);
        memoryStream.Position = 0;

        return Task.FromResult<Stream>(memoryStream);
    }
}
