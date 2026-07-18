using System;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Models;

var optionsBuilder = new DbContextOptionsBuilder<PharmacyDbContext>();
optionsBuilder.UseNpgsql("Host=aws-0-ap-northeast-1.pooler.supabase.com;Port=5432;Database=postgres;Username=postgres.mohzctrdjgwajlxiylkn;Password=29032004h@H310824miku@M;Pooling=false;KeepAlive=30;");
using var context = new PharmacyDbContext(optionsBuilder.Options);

var statuses = context.PaymentTransactions.Select(t => t.PaymentStatus).Distinct().ToList();
Console.WriteLine("Transaction Statuses: " + string.Join(", ", statuses));

var invStatuses = context.Invoices.Select(t => t.PaymentStatus).Distinct().ToList();
Console.WriteLine("Invoice Statuses: " + string.Join(", ", invStatuses));
