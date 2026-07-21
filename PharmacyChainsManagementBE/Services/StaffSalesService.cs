using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using PharmacyChainsManagementBE.Common.Settings;
using PharmacyChainsManagementBE.Common.Exceptions;
using PharmacyChainsManagementBE.DTOs.StaffSales;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Services;

public sealed class StaffSalesService : IStaffSalesService
{
    private readonly PharmacyDbContext _context;
    private readonly QrPaymentSettings _qrPaymentSettings;
    private readonly CurrencyConversionSettings _currencyConversionSettings;

    public StaffSalesService(
        PharmacyDbContext context,
        IOptions<QrPaymentSettings> qrPaymentSettings,
        IOptions<CurrencyConversionSettings> currencyConversionSettings)
    {
        _context = context;
        _qrPaymentSettings = qrPaymentSettings.Value;
        _currencyConversionSettings = currencyConversionSettings.Value;
    }

    public async Task<IReadOnlyList<MedicineSearchResponseDto>> SearchMedicinesAsync(Guid staffId, string? search, string? category, string? availability, CancellationToken cancellationToken)
    {
        var branchId = await GetStaffBranchIdAsync(staffId, cancellationToken);
        var query = _context.Inventories.AsNoTracking()
            .Include(item => item.Medicine)
            .Include(item => item.Batch)
            .Where(item => item.BranchId == branchId && item.QuantityOnHand > 0 && item.Batch.ExpiryDate > DateOnly.FromDateTime(DateTime.UtcNow));

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim().ToLower();
            query = query.Where(item => item.Medicine.MedicineName.ToLower().Contains(term) || item.Batch.BatchNumber.ToLower().Contains(term));
        }
        if (!string.IsNullOrWhiteSpace(category)) query = query.Where(item => item.Medicine.Category == category);

        var rows = await query.ToListAsync(cancellationToken);
        var medicines = rows.GroupBy(item => item.MedicineId).Select(group =>
        {
            var quantity = group.Sum(item => item.QuantityOnHand);
            var safetyLevel = group.Max(item => item.SafetyStockLevel);
            var stockStatus = quantity <= safetyLevel ? "LOW" : "IN_STOCK";
            return new MedicineSearchResponseDto(group.Key, group.First().Medicine.MedicineName, group.First().Medicine.Category,
                group.First().Medicine.Unit, group.First().Medicine.StandardPrice, quantity, safetyLevel, stockStatus,
                group.Min(item => item.Batch.ExpiryDate));
        });
        if (string.Equals(availability, "low", StringComparison.OrdinalIgnoreCase)) medicines = medicines.Where(item => item.StockStatus == "LOW");
        return medicines.OrderBy(item => item.MedicineName).ToList();
    }

    public async Task<InvoiceResponseDto> CreateInvoiceAsync(Guid staffId, CreateInvoiceRequestDto request, CancellationToken cancellationToken)
    {
        if (request.Items.Count == 0 || request.Items.Any(item => item.Quantity <= 0)) throw new InvalidOperationException("Invoice must contain at least one item with a positive quantity.");
        var branchId = await GetStaffBranchIdAsync(staffId, cancellationToken);
        await using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);
        var invoice = new Invoice
        {
            InvoiceId = Guid.NewGuid(), BranchId = branchId, StaffId = staffId,
            InvoiceCode = $"INV-{DateTime.UtcNow:yyyyMMddHHmmss}-{Guid.NewGuid().ToString("N")[..4].ToUpperInvariant()}",
            InvoiceDate = DateOnly.FromDateTime(DateTime.UtcNow), PaymentStatus = "UNPAID", Status = "ACTIVE",
            CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow
        };

        foreach (var requestItem in request.Items)
        {
            var inventory = await _context.Inventories.Include(item => item.Medicine).Include(item => item.Batch)
                .Where(item => item.BranchId == branchId && item.MedicineId == requestItem.MedicineId && item.QuantityOnHand >= requestItem.Quantity && item.Batch.ExpiryDate > DateOnly.FromDateTime(DateTime.UtcNow))
                .OrderBy(item => item.Batch.ExpiryDate).FirstOrDefaultAsync(cancellationToken);
            if (inventory is null) throw new InvalidOperationException("Insufficient available stock for a selected medicine.");
            inventory.QuantityOnHand -= requestItem.Quantity;
            inventory.UpdatedAt = DateTime.UtcNow;
            var lineTotal = inventory.Medicine.StandardPrice * requestItem.Quantity;
            invoice.InvoiceDetails.Add(new InvoiceDetail { InvoiceDetailId = Guid.NewGuid(), InvoiceId = invoice.InvoiceId, MedicineId = inventory.MedicineId, BatchId = inventory.BatchId, Quantity = requestItem.Quantity, UnitPrice = inventory.Medicine.StandardPrice, LineTotal = lineTotal });
        }
        invoice.TotalAmount = invoice.InvoiceDetails.Sum(item => item.LineTotal);
        _context.Invoices.Add(invoice);
        await _context.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);
        return await GetInvoiceAsync(staffId, invoice.InvoiceId, cancellationToken);
    }

    public async Task<IReadOnlyList<InvoiceListItemResponseDto>> GetInvoicesAsync(Guid staffId, string? search, string? paymentStatus, DateOnly? fromDate, DateOnly? toDate, CancellationToken cancellationToken)
    {
        var branchId = await GetStaffBranchIdAsync(staffId, cancellationToken);
        var query = _context.Invoices.AsNoTracking().Include(invoice => invoice.InvoiceDetails).Where(invoice => invoice.BranchId == branchId);
        if (!string.IsNullOrWhiteSpace(search)) query = query.Where(invoice => invoice.InvoiceCode.Contains(search));
        if (!string.IsNullOrWhiteSpace(paymentStatus)) query = query.Where(invoice => invoice.PaymentStatus.ToUpper() == paymentStatus.ToUpper());
        if (fromDate.HasValue) query = query.Where(invoice => invoice.InvoiceDate >= fromDate.Value);
        if (toDate.HasValue) query = query.Where(invoice => invoice.InvoiceDate <= toDate.Value);
        return await query.OrderByDescending(invoice => invoice.CreatedAt).Select(invoice => new InvoiceListItemResponseDto(invoice.InvoiceId, invoice.InvoiceCode, invoice.InvoiceDate, invoice.TotalAmount, invoice.PaymentStatus.ToUpper(), invoice.Status.ToUpper(), invoice.InvoiceDetails.Count)).ToListAsync(cancellationToken);
    }

    public async Task<InvoiceResponseDto> GetInvoiceAsync(Guid staffId, Guid invoiceId, CancellationToken cancellationToken)
    {
        var branchId = await GetStaffBranchIdAsync(staffId, cancellationToken);
        var invoice = await _context.Invoices.AsNoTracking().Include(item => item.InvoiceDetails).ThenInclude(item => item.Medicine).Include(item => item.InvoiceDetails).ThenInclude(item => item.Batch)
            .SingleOrDefaultAsync(item => item.InvoiceId == invoiceId && item.BranchId == branchId, cancellationToken) ?? throw new DataNotFoundException("Invoice was not found.");
        return new InvoiceResponseDto(invoice.InvoiceId, invoice.InvoiceCode, invoice.InvoiceDate, invoice.TotalAmount, invoice.PaymentStatus.ToUpperInvariant(), invoice.Status.ToUpperInvariant(),
            invoice.InvoiceDetails.Select(item => new InvoiceLineResponseDto(item.InvoiceDetailId, item.MedicineId, item.Medicine.MedicineName, item.BatchId, item.Batch.BatchNumber, item.Quantity, item.UnitPrice, item.LineTotal)).ToList());
    }

    public async Task<PaymentTransactionResponseDto> CreateMockPaymentAsync(Guid staffId, Guid invoiceId, CreatePaymentRequestDto request, CancellationToken cancellationToken)
    {
        var branchId = await GetStaffBranchIdAsync(staffId, cancellationToken);
        var invoice = await _context.Invoices
            .Include(item => item.InvoiceDetails)
            .SingleOrDefaultAsync(
                item => item.InvoiceId == invoiceId && item.BranchId == branchId,
                cancellationToken)
            ?? throw new DataNotFoundException("Invoice was not found.");

        var now = DateTime.UtcNow;
        if (IsExpiredUnpaidInvoice(invoice, now))
        {
            await CancelInvoiceAndRestoreStockAsync(invoice, now, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
            throw new InvalidOperationException("This unpaid invoice has expired and was cancelled.");
        }

        if (string.Equals(invoice.PaymentStatus, "PAID", StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("This invoice has already been paid.");
        if (!string.Equals(invoice.Status, "ACTIVE", StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Only active invoices can be processed for payment.");
        var methods = new[] { "CASH", "QR" };
        var paymentMethod = request.PaymentMethod.ToUpperInvariant();
        if (!methods.Contains(paymentMethod)) throw new InvalidOperationException("Unsupported payment method.");
        if (paymentMethod == "QR") ValidateQrSettings();
        var exchangeRate = paymentMethod == "QR"
            ? GetConfiguredUsdToVndRate()
            : (decimal?)null;
        var expectedAmountVnd = exchangeRate.HasValue
            ? decimal.Round(invoice.TotalAmount * exchangeRate.Value, 0, MidpointRounding.AwayFromZero)
            : (decimal?)null;
        var payment = new PaymentTransaction
        {
            PaymentId = Guid.NewGuid(),
            InvoiceId = invoice.InvoiceId,
            Amount = invoice.TotalAmount,
            ExchangeRate = exchangeRate,
            ExpectedAmountVnd = expectedAmountVnd,
            BaseCurrency = _currencyConversionSettings.BaseCurrency.ToUpperInvariant(),
            SettlementCurrency = paymentMethod == "QR"
                ? _currencyConversionSettings.PaymentCurrency.ToUpperInvariant()
                : _currencyConversionSettings.BaseCurrency.ToUpperInvariant(),
            PaymentMethod = paymentMethod,
            PaymentStatus = paymentMethod == "QR" ? "PENDING" : "PAID",
            PaymentDate = paymentMethod == "QR" ? null : now,
            GatewayReference = paymentMethod == "QR"
                ? $"PCMS{Guid.NewGuid().ToString("N")[..12].ToUpperInvariant()}"
                : $"MOCK-{Guid.NewGuid().ToString("N")[..10].ToUpperInvariant()}",
            CreatedAt = now,
            UpdatedAt = now
        };
        if (paymentMethod != "QR") invoice.PaymentStatus = "PAID";
        invoice.UpdatedAt = now;
        _context.PaymentTransactions.Add(payment);
        await _context.SaveChangesAsync(cancellationToken);
        return ToPaymentDto(payment, invoice.InvoiceCode);
    }

    public async Task<PaymentTransactionResponseDto> GetPaymentAsync(Guid staffId, Guid paymentId, CancellationToken cancellationToken)
    {
        var branchId = await GetStaffBranchIdAsync(staffId, cancellationToken);
        var payment = await _context.PaymentTransactions
            .Include(item => item.Invoice)
            .ThenInclude(invoice => invoice.InvoiceDetails)
            .SingleOrDefaultAsync(
                item => item.PaymentId == paymentId && item.Invoice.BranchId == branchId,
                cancellationToken)
            ?? throw new DataNotFoundException("Payment transaction was not found.");

        if (payment.PaymentMethod == "QR"
            && string.Equals(payment.PaymentStatus, "PENDING", StringComparison.OrdinalIgnoreCase)
            && payment.CreatedAt.AddMinutes(_qrPaymentSettings.ExpirationMinutes) <= DateTime.UtcNow)
        {
            await CancelExpiredQrPaymentAsync(payment, DateTime.UtcNow, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
        }

        return ToPaymentDto(payment, payment.Invoice.InvoiceCode);
    }

    public async Task<int> CancelExpiredQrInvoicesAsync(CancellationToken cancellationToken)
    {
        await using var transaction = await _context.Database.BeginTransactionAsync(
            IsolationLevel.Serializable,
            cancellationToken);
        var now = DateTime.UtcNow;
        var cancelledInvoiceIds = new HashSet<Guid>();

        var qrCutoff = now.AddMinutes(-_qrPaymentSettings.ExpirationMinutes);
        var expiredQrPayments = await _context.PaymentTransactions
            .Include(item => item.Invoice)
            .ThenInclude(invoice => invoice.InvoiceDetails)
            .Where(item => item.PaymentMethod == "QR"
                && item.PaymentStatus.ToUpper() == "PENDING"
                && item.CreatedAt <= qrCutoff)
            .ToListAsync(cancellationToken);

        foreach (var payment in expiredQrPayments)
        {
            if (string.Equals(payment.Invoice.Status, "ACTIVE", StringComparison.OrdinalIgnoreCase))
            {
                cancelledInvoiceIds.Add(payment.InvoiceId);
            }

            await CancelExpiredQrPaymentAsync(payment, now, cancellationToken);
        }

        var invoiceCutoff = now.AddMinutes(-GetInvoiceExpirationMinutes());
        var expiredInvoices = await _context.Invoices
            .Include(item => item.InvoiceDetails)
            .Include(item => item.PaymentTransactions)
            .Where(item => item.Status.ToUpper() == "ACTIVE"
                && item.PaymentStatus.ToUpper() == "UNPAID"
                && item.CreatedAt <= invoiceCutoff)
            .ToListAsync(cancellationToken);

        foreach (var invoice in expiredInvoices)
        {
            if (!string.Equals(invoice.Status, "ACTIVE", StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            cancelledInvoiceIds.Add(invoice.InvoiceId);
            foreach (var payment in invoice.PaymentTransactions.Where(item =>
                         item.PaymentMethod == "QR"
                         && item.PaymentStatus.ToUpper() == "PENDING"))
            {
                payment.PaymentStatus = "EXPIRED";
                payment.UpdatedAt = now;
            }

            await CancelInvoiceAndRestoreStockAsync(invoice, now, cancellationToken);
        }

        if (expiredQrPayments.Count > 0 || expiredInvoices.Count > 0)
        {
            await _context.SaveChangesAsync(cancellationToken);
        }

        await transaction.CommitAsync(cancellationToken);
        return cancelledInvoiceIds.Count;
    }

    public async Task ProcessSePayWebhookAsync(
        SePayWebhookRequestDto request,
        CancellationToken cancellationToken)
    {
        if (!string.Equals(request.TransferType, "in", StringComparison.OrdinalIgnoreCase)
            || string.IsNullOrWhiteSpace(request.Code))
        {
            return;
        }

        await using var transaction = await _context.Database.BeginTransactionAsync(
            IsolationLevel.Serializable,
            cancellationToken);
        var payment = await _context.PaymentTransactions
            .Include(item => item.Invoice)
            .ThenInclude(invoice => invoice.InvoiceDetails)
            .SingleOrDefaultAsync(
                item => item.PaymentMethod == "QR"
                    && item.GatewayReference != null
                    && item.GatewayReference.StartsWith(request.Code),
                cancellationToken);

        if (payment is null
            || !string.Equals(payment.PaymentStatus, "PENDING", StringComparison.OrdinalIgnoreCase))
        {
            await transaction.CommitAsync(cancellationToken);
            return;
        }

        var now = DateTime.UtcNow;
        if (string.Equals(payment.PaymentStatus, "PENDING", StringComparison.OrdinalIgnoreCase)
            && payment.CreatedAt.AddMinutes(_qrPaymentSettings.ExpirationMinutes) <= now)
        {
            await CancelExpiredQrPaymentAsync(payment, now, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return;
        }

        var virtualAccountMatches =
            string.IsNullOrWhiteSpace(_qrPaymentSettings.VirtualAccount)
            || string.Equals(
                request.SubAccount,
                _qrPaymentSettings.VirtualAccount,
                StringComparison.OrdinalIgnoreCase);

        payment.ReceivedAmountVnd = request.TransferAmount;

        if (!string.Equals(
                request.AccountNumber,
                _qrPaymentSettings.AccountNumber,
                StringComparison.Ordinal)
            || !virtualAccountMatches
            || !payment.ExpectedAmountVnd.HasValue
            || request.TransferAmount != payment.ExpectedAmountVnd.Value)
        {
            payment.PaymentStatus = "AMOUNT_MISMATCH";
            payment.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return;
        }

        payment.PaymentStatus = "PAID";
        payment.PaymentDate = now;
        payment.GatewayReference =
            $"{request.Code}|{request.Id}|{request.ReferenceCode ?? request.Gateway}";
        payment.UpdatedAt = now;
        payment.Invoice.PaymentStatus = "PAID";
        payment.Invoice.UpdatedAt = now;
        await _context.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<PaymentTransactionResponseDto>> GetPaymentsAsync(Guid staffId, string? paymentStatus, CancellationToken cancellationToken)
    {
        var branchId = await GetStaffBranchIdAsync(staffId, cancellationToken);
        var query = _context.PaymentTransactions.AsNoTracking().Include(item => item.Invoice).Where(item => item.Invoice.BranchId == branchId);
        if (!string.IsNullOrWhiteSpace(paymentStatus)) query = query.Where(item => item.PaymentStatus.ToUpper() == paymentStatus.ToUpper());
        var payments = await query.OrderByDescending(item => item.CreatedAt).ToListAsync(cancellationToken);
        return payments.Select(item => ToPaymentDto(item, item.Invoice.InvoiceCode)).ToList();
    }

    public async Task<StaffDashboardResponseDto> GetDashboardAsync(Guid staffId, CancellationToken cancellationToken)
    {
        var branchId = await GetStaffBranchIdAsync(staffId, cancellationToken);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var invoices = _context.Invoices.AsNoTracking().Where(item => item.BranchId == branchId && item.InvoiceDate == today);
        var lowStock = await _context.Inventories.AsNoTracking().CountAsync(item => item.BranchId == branchId && item.QuantityOnHand <= item.SafetyStockLevel, cancellationToken);
        return new StaffDashboardResponseDto(await invoices.Where(item => item.PaymentStatus.ToUpper() == "PAID").SumAsync(item => (decimal?)item.TotalAmount, cancellationToken) ?? 0m,
            await invoices.CountAsync(cancellationToken), await _context.Invoices.CountAsync(item => item.BranchId == branchId && item.PaymentStatus.ToUpper() == "UNPAID", cancellationToken), lowStock, "08:00 - 16:00");
    }

    private async Task<Guid> GetStaffBranchIdAsync(Guid staffId, CancellationToken cancellationToken) =>
        await _context.Users.AsNoTracking().Where(user => user.UserId == staffId && user.Status == "ACTIVE").Select(user => user.BranchId).SingleOrDefaultAsync(cancellationToken)
        ?? throw new InvalidOperationException("The staff account is not assigned to an active branch.");

    private async Task CancelExpiredQrPaymentAsync(
        PaymentTransaction payment,
        DateTime now,
        CancellationToken cancellationToken)
    {
        if (!string.Equals(payment.PaymentStatus, "PENDING", StringComparison.OrdinalIgnoreCase)
            || payment.CreatedAt.AddMinutes(_qrPaymentSettings.ExpirationMinutes) > now)
        {
            return;
        }

        payment.PaymentStatus = "EXPIRED";
        payment.UpdatedAt = now;

        await CancelInvoiceAndRestoreStockAsync(payment.Invoice, now, cancellationToken);
    }

    private bool IsExpiredUnpaidInvoice(Invoice invoice, DateTime now) =>
        string.Equals(invoice.Status, "ACTIVE", StringComparison.OrdinalIgnoreCase)
        && string.Equals(invoice.PaymentStatus, "UNPAID", StringComparison.OrdinalIgnoreCase)
        && invoice.CreatedAt.AddMinutes(GetInvoiceExpirationMinutes()) <= now;

    private int GetInvoiceExpirationMinutes() =>
        _qrPaymentSettings.InvoiceExpirationMinutes > 0
            ? _qrPaymentSettings.InvoiceExpirationMinutes
            : 30;

    private async Task CancelInvoiceAndRestoreStockAsync(
        Invoice invoice,
        DateTime now,
        CancellationToken cancellationToken)
    {
        if (!string.Equals(invoice.Status, "ACTIVE", StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        invoice.Status = "CANCELLED";
        invoice.UpdatedAt = now;

        foreach (var group in invoice.InvoiceDetails.GroupBy(item => item.BatchId))
        {
            var inventory = await _context.Inventories.SingleOrDefaultAsync(
                item => item.BranchId == invoice.BranchId
                    && item.BatchId == group.Key,
                cancellationToken);
            if (inventory is null)
            {
                continue;
            }

            inventory.QuantityOnHand += group.Sum(item => item.Quantity);
            inventory.UpdatedAt = now;
        }
    }

    private PaymentTransactionResponseDto ToPaymentDto(PaymentTransaction payment, string invoiceCode)
    {
        if (payment.PaymentMethod != "QR")
        {
            return new PaymentTransactionResponseDto(
                payment.PaymentId, payment.InvoiceId, invoiceCode, payment.Amount,
                payment.ExchangeRate, payment.ExpectedAmountVnd, payment.ReceivedAmountVnd,
                payment.BaseCurrency, payment.SettlementCurrency,
                payment.PaymentMethod, payment.PaymentStatus, payment.PaymentDate,
                payment.GatewayReference, null, null, null, null, null, null);
        }

        if (!IsQrConfigured())
        {
            return new PaymentTransactionResponseDto(
                payment.PaymentId, payment.InvoiceId, invoiceCode, payment.Amount,
                payment.ExchangeRate, payment.ExpectedAmountVnd, payment.ReceivedAmountVnd,
                payment.BaseCurrency, payment.SettlementCurrency,
                payment.PaymentMethod, payment.PaymentStatus, payment.PaymentDate,
                payment.GatewayReference, null, null, null, null, null, null);
        }

        var transferContent = payment.GatewayReference?.Split('|')[0] ?? invoiceCode;
        var amount = payment.ExpectedAmountVnd?.ToString(
            "0",
            System.Globalization.CultureInfo.InvariantCulture)
            ?? throw new InvalidOperationException("The QR payment does not have a VND settlement amount.");
        var paymentAccountNumber = string.IsNullOrWhiteSpace(_qrPaymentSettings.VirtualAccount)
            ? _qrPaymentSettings.AccountNumber
            : _qrPaymentSettings.VirtualAccount;
        var qrCodeUrl =
            $"https://img.vietqr.io/image/{Uri.EscapeDataString(_qrPaymentSettings.BankBin)}-" +
            $"{Uri.EscapeDataString(paymentAccountNumber)}-compact2.png" +
            $"?amount={amount}" +
            $"&addInfo={Uri.EscapeDataString(transferContent)}" +
            $"&accountName={Uri.EscapeDataString(_qrPaymentSettings.AccountName)}";

        return new PaymentTransactionResponseDto(
            payment.PaymentId, payment.InvoiceId, invoiceCode, payment.Amount,
            payment.ExchangeRate, payment.ExpectedAmountVnd, payment.ReceivedAmountVnd,
            payment.BaseCurrency, payment.SettlementCurrency,
            payment.PaymentMethod, payment.PaymentStatus, payment.PaymentDate,
            payment.GatewayReference, qrCodeUrl, _qrPaymentSettings.BankName,
            _qrPaymentSettings.AccountName, MaskAccountNumber(paymentAccountNumber),
            transferContent, payment.CreatedAt.AddMinutes(_qrPaymentSettings.ExpirationMinutes));
    }

    private void ValidateQrSettings()
    {
        if (!IsQrConfigured())
        {
            throw new InvalidOperationException("QR payment has not been configured for this environment.");
        }
    }

    private decimal GetConfiguredUsdToVndRate()
    {
        if (_currencyConversionSettings.UsdToVndRate <= 0
            || !string.Equals(_currencyConversionSettings.BaseCurrency, "USD", StringComparison.OrdinalIgnoreCase)
            || !string.Equals(_currencyConversionSettings.PaymentCurrency, "VND", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("USD to VND currency conversion has not been configured correctly.");
        }

        return _currencyConversionSettings.UsdToVndRate;
    }

    private bool IsQrConfigured() =>
        !string.IsNullOrWhiteSpace(_qrPaymentSettings.BankBin)
        && !string.IsNullOrWhiteSpace(_qrPaymentSettings.BankName)
        && !string.IsNullOrWhiteSpace(_qrPaymentSettings.AccountNumber)
        && !string.IsNullOrWhiteSpace(_qrPaymentSettings.AccountName);

    private static string MaskAccountNumber(string accountNumber) =>
        accountNumber.Length <= 4
            ? accountNumber
            : new string('*', accountNumber.Length - 4) + accountNumber[^4..];
}
