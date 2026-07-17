using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using PharmacyChainsManagementBE.DTOs.Finance;

namespace PharmacyChainsManagementBE.Services.Strategies;

public class PdfExportStrategy : IExportFormatStrategy<ReportPayloadDTO>
{
    public string ContentType => "application/pdf";

    public string GetFileName()
    {
        return $"financial_report_{DateTime.UtcNow:yyyyMMddHHmmss}.pdf";
    }

    public Task<Stream> GenerateAndFormatAsync(ReportPayloadDTO payload, CancellationToken cancellationToken = default)
    {
        QuestPDF.Settings.License = LicenseType.Community;

        var memoryStream = new MemoryStream();

        Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.PageColor(Colors.White);
                page.DefaultTextStyle(x => x.FontSize(10));

                page.Header().Element(ComposeHeader);
                page.Content().Element(x => ComposeContent(x, payload));
                page.Footer().Element(ComposeFooter);
            });
        })
        .GeneratePdf(memoryStream);

        memoryStream.Position = 0;
        return Task.FromResult<Stream>(memoryStream);
    }

    private void ComposeHeader(IContainer container)
    {
        container.Row(row =>
        {
            row.RelativeItem().Column(column =>
            {
                column.Item().Text("Financial Report").FontSize(20).SemiBold().FontColor(Colors.Blue.Darken2);
                column.Item().Text($"Generated at {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss}");
            });
        });
    }

    private void ComposeContent(IContainer container, ReportPayloadDTO payload)
    {
        container.PaddingVertical(1, Unit.Centimetre).Column(column =>
        {
            column.Spacing(5);

            column.Item().Text($"Branch ID: {payload.BranchId}");
            column.Item().Text($"Period: {payload.StartDate:yyyy-MM-dd} to {payload.EndDate:yyyy-MM-dd}");
            column.Item().Text($"Total Revenue: {payload.TotalRevenue}");
            column.Item().Text($"Total Transactions: {payload.TotalTransactions}");

            column.Item().PaddingTop(25).Table(table =>
            {
                table.ColumnsDefinition(columns =>
                {
                    columns.RelativeColumn(3); // Payment ID
                    columns.RelativeColumn(3); // Invoice ID
                    columns.RelativeColumn(2); // Amount
                    columns.RelativeColumn(2); // Payment Method
                    columns.RelativeColumn(2); // Status
                    columns.RelativeColumn(3); // Date
                });

                table.Header(header =>
                {
                    header.Cell().Text("Payment ID").SemiBold();
                    header.Cell().Text("Invoice ID").SemiBold();
                    header.Cell().Text("Amount").SemiBold();
                    header.Cell().Text("Method").SemiBold();
                    header.Cell().Text("Status").SemiBold();
                    header.Cell().Text("Date").SemiBold();
                    header.Cell().ColumnSpan(6).PaddingTop(5).BorderBottom(1).BorderColor(Colors.Black);
                });

                foreach (var t in payload.Transactions)
                {
                    table.Cell().Text(t.PaymentId.ToString().Substring(0, 8) + "...");
                    table.Cell().Text(t.InvoiceId.ToString().Substring(0, 8) + "...");
                    table.Cell().Text(t.Amount.ToString());
                    table.Cell().Text(t.PaymentMethod);
                    table.Cell().Text(t.PaymentStatus);
                    table.Cell().Text(t.PaymentDate?.ToString("yyyy-MM-dd HH:mm"));
                }
            });
        });
    }

    private void ComposeFooter(IContainer container)
    {
        container.AlignCenter().Text(x =>
        {
            x.Span("Page ");
            x.CurrentPageNumber();
            x.Span(" of ");
            x.TotalPages();
        });
    }
}
