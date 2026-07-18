using System;
using System.IO;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.DTOs.Finance;

namespace PharmacyChainsManagementBE.Services.Strategies;

public class CsvExportStrategy : IExportFormatStrategy<ReportPayloadDTO>
{
    public string ContentType => "text/csv";

    public string GetFileName()
    {
        return $"financial_report_{DateTime.UtcNow:yyyyMMddHHmmss}.csv";
    }

    public async Task<Stream> GenerateAndFormatAsync(ReportPayloadDTO payload, CancellationToken cancellationToken = default)
    {
        var memoryStream = new MemoryStream();
        // leaveOpen: true so we don't dispose the stream when writer disposes
        await using var writer = new StreamWriter(memoryStream, Encoding.UTF8, 1024, leaveOpen: true);
        
        await writer.WriteLineAsync("BranchId,StartDate,EndDate,TotalRevenue,TotalTransactions");
        await writer.WriteLineAsync($"{Sanitize(payload.BranchId.ToString())},{payload.StartDate:yyyy-MM-dd},{payload.EndDate:yyyy-MM-dd},{payload.TotalRevenue},{payload.TotalTransactions}");
        
        await writer.WriteLineAsync();
        
        await writer.WriteLineAsync("PaymentId,InvoiceId,Amount,PaymentMethod,PaymentStatus,PaymentDate");
        foreach (var t in payload.Transactions)
        {
            await writer.WriteLineAsync($"{Sanitize(t.PaymentId.ToString())},{Sanitize(t.InvoiceId.ToString())},{t.Amount},{Sanitize(t.PaymentMethod)},{Sanitize(t.PaymentStatus)},{t.PaymentDate?.ToString("yyyy-MM-dd HH:mm:ss")}");
        }
        
        await writer.FlushAsync(cancellationToken);
        memoryStream.Position = 0;
        return memoryStream;
    }
    
    private static string Sanitize(string? value)
    {
        if (string.IsNullOrEmpty(value))
        {
            return string.Empty;
        }
        
        // CSV Injection Sanitization (Enhancement BE3)
        // Prevent formula injection if it starts with =, +, -, or @
        if (value.StartsWith("=") || value.StartsWith("+") || value.StartsWith("-") || value.StartsWith("@"))
        {
            value = "\t" + value;
        }
        
        // Escape quotes and wrap in quotes if contains comma
        if (value.Contains(",") || value.Contains("\""))
        {
            return $"\"{value.Replace("\"", "\"\"")}\"";
        }
        
        return value;
    }
}
