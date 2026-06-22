using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

public partial class PharmacyDbContext : DbContext
{
    public PharmacyDbContext()
    {
    }

    public PharmacyDbContext(DbContextOptions<PharmacyDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<AuditLog> AuditLogs { get; set; }

    public virtual DbSet<Branch> Branches { get; set; }

    public virtual DbSet<Inventory> Inventories { get; set; }

    public virtual DbSet<Invoice> Invoices { get; set; }

    public virtual DbSet<InvoiceDetail> InvoiceDetails { get; set; }

    public virtual DbSet<Medicine> Medicines { get; set; }

    public virtual DbSet<MedicineBatch> MedicineBatches { get; set; }

    public virtual DbSet<PaymentGateway> PaymentGateways { get; set; }

    public virtual DbSet<PaymentTransaction> PaymentTransactions { get; set; }

    public virtual DbSet<Prescription> Prescriptions { get; set; }

    public virtual DbSet<PrescriptionDetail> PrescriptionDetails { get; set; }

    public virtual DbSet<PurchaseOrder> PurchaseOrders { get; set; }

    public virtual DbSet<PurchaseOrderDetail> PurchaseOrderDetails { get; set; }

    public virtual DbSet<Report> Reports { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<StockTransfer> StockTransfers { get; set; }

    public virtual DbSet<StockTransferDetail> StockTransferDetails { get; set; }

    public virtual DbSet<Supplier> Suppliers { get; set; }

    public virtual DbSet<User> Users { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=SQL1002.site4now.net;Initial Catalog=db_acafda_pharmacychains;User Id=db_acafda_pharmacychains_admin;Password=29033108@hm;Encrypt=True;TrustServerCertificate=True;");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AuditLog>(entity =>
        {
            entity.HasKey(e => e.AuditId).HasName("PK__AUDIT_LO__5AF33E33EA16EB9D");

            entity.Property(e => e.AuditId).ValueGeneratedNever();

            entity.HasOne(d => d.Actor).WithMany(p => p.AuditLogs)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AUD_ACTOR");
        });

        modelBuilder.Entity<Branch>(entity =>
        {
            entity.HasKey(e => e.BranchId).HasName("PK__BRANCH__E55E37DE2FFC4385");

            entity.Property(e => e.BranchId).ValueGeneratedNever();
        });

        modelBuilder.Entity<Inventory>(entity =>
        {
            entity.HasKey(e => e.InventoryId).HasName("PK__INVENTOR__B59ACC4968023E2D");

            entity.Property(e => e.InventoryId).ValueGeneratedNever();

            entity.HasOne(d => d.Batch).WithMany(p => p.Inventories)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_INV_BATCH");

            entity.HasOne(d => d.Branch).WithMany(p => p.Inventories)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_INV_BRANCH");

            entity.HasOne(d => d.Medicine).WithMany(p => p.Inventories)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_INV_MEDICINE");
        });

        modelBuilder.Entity<Invoice>(entity =>
        {
            entity.HasKey(e => e.InvoiceId).HasName("PK__INVOICE__F58DFD49258ACF2C");

            entity.Property(e => e.InvoiceId).ValueGeneratedNever();

            entity.HasOne(d => d.Branch).WithMany(p => p.Invoices)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_INV_BRANCH_2");

            entity.HasOne(d => d.Prescription).WithMany(p => p.Invoices).HasConstraintName("FK_INV_PRESCRIPTION");

            entity.HasOne(d => d.Staff).WithMany(p => p.Invoices)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_INV_STAFF");
        });

        modelBuilder.Entity<InvoiceDetail>(entity =>
        {
            entity.HasKey(e => e.InvoiceDetailId).HasName("PK__INVOICE___84908DB6027EFE8E");

            entity.Property(e => e.InvoiceDetailId).ValueGeneratedNever();

            entity.HasOne(d => d.Batch).WithMany(p => p.InvoiceDetails)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_INVD_BATCH");

            entity.HasOne(d => d.Invoice).WithMany(p => p.InvoiceDetails)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_INVD_INVOICE");

            entity.HasOne(d => d.Medicine).WithMany(p => p.InvoiceDetails)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_INVD_MEDICINE");
        });

        modelBuilder.Entity<Medicine>(entity =>
        {
            entity.HasKey(e => e.MedicineId).HasName("PK__MEDICINE__E7148EBBD592791F");

            entity.Property(e => e.MedicineId).ValueGeneratedNever();
        });

        modelBuilder.Entity<MedicineBatch>(entity =>
        {
            entity.HasKey(e => e.BatchId).HasName("PK__MEDICINE__DBFC0431E550911D");

            entity.Property(e => e.BatchId).ValueGeneratedNever();

            entity.HasOne(d => d.Medicine).WithMany(p => p.MedicineBatches)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_BATCH_MEDICINE");

            entity.HasOne(d => d.Supplier).WithMany(p => p.MedicineBatches)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_BATCH_SUPPLIER");
        });

        modelBuilder.Entity<PaymentGateway>(entity =>
        {
            entity.HasKey(e => e.GatewayId).HasName("PK__PAYMENT___0AF5B00B3EAC3274");

            entity.Property(e => e.GatewayId).ValueGeneratedNever();
            entity.Property(e => e.IsActive).HasDefaultValue(true);
        });

        modelBuilder.Entity<PaymentTransaction>(entity =>
        {
            entity.HasKey(e => e.PaymentId).HasName("PK__PAYMENT___ED1FC9EA5BA1EC89");

            entity.Property(e => e.PaymentId).ValueGeneratedNever();

            entity.HasOne(d => d.Gateway).WithMany(p => p.PaymentTransactions).HasConstraintName("FK_PAY_GATEWAY");

            entity.HasOne(d => d.Invoice).WithMany(p => p.PaymentTransactions)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PAY_INVOICE");
        });

        modelBuilder.Entity<Prescription>(entity =>
        {
            entity.HasKey(e => e.PrescriptionId).HasName("PK__PRESCRIP__3EE444F81A0DC9F6");

            entity.Property(e => e.PrescriptionId).ValueGeneratedNever();

            entity.HasOne(d => d.Branch).WithMany(p => p.Prescriptions)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PRES_BRANCH");

            entity.HasOne(d => d.Staff).WithMany(p => p.Prescriptions)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PRES_STAFF");
        });

        modelBuilder.Entity<PrescriptionDetail>(entity =>
        {
            entity.HasKey(e => e.PrescriptionDetailId).HasName("PK__PRESCRIP__CD190C8BB0BF34DD");

            entity.Property(e => e.PrescriptionDetailId).ValueGeneratedNever();

            entity.HasOne(d => d.Medicine).WithMany(p => p.PrescriptionDetails)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PRESD_MEDICINE");

            entity.HasOne(d => d.Prescription).WithMany(p => p.PrescriptionDetails)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PRESD_PRESCRIPTION");
        });

        modelBuilder.Entity<PurchaseOrder>(entity =>
        {
            entity.HasKey(e => e.PoId).HasName("PK__PURCHASE__368DA7F09A44F7AA");

            entity.Property(e => e.PoId).ValueGeneratedNever();

            entity.HasOne(d => d.ApprovedByNavigation).WithMany(p => p.PurchaseOrderApprovedByNavigations).HasConstraintName("FK_PO_APPROVED_BY");

            entity.HasOne(d => d.Branch).WithMany(p => p.PurchaseOrders)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PO_BRANCH");

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.PurchaseOrderCreatedByNavigations)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PO_CREATED_BY");

            entity.HasOne(d => d.Supplier).WithMany(p => p.PurchaseOrders)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PO_SUPPLIER");
        });

        modelBuilder.Entity<PurchaseOrderDetail>(entity =>
        {
            entity.HasKey(e => e.PoDetailId).HasName("PK__PURCHASE__9E6103B2CC7E0FEF");

            entity.Property(e => e.PoDetailId).ValueGeneratedNever();

            entity.HasOne(d => d.Medicine).WithMany(p => p.PurchaseOrderDetails)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_POD_MEDICINE");

            entity.HasOne(d => d.Po).WithMany(p => p.PurchaseOrderDetails)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_POD_PO");
        });

        modelBuilder.Entity<Report>(entity =>
        {
            entity.HasKey(e => e.ReportId).HasName("PK__REPORT__779B7C58AB9D0C61");

            entity.Property(e => e.ReportId).ValueGeneratedNever();

            entity.HasOne(d => d.GeneratedByNavigation).WithMany(p => p.Reports)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_REP_GENERATED_BY");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.RoleId).HasName("PK__ROLE__760965CC18C3E6A4");

            entity.Property(e => e.RoleId).ValueGeneratedNever();
            entity.Property(e => e.IsActive).HasDefaultValue(true);
        });

        modelBuilder.Entity<StockTransfer>(entity =>
        {
            entity.HasKey(e => e.TransferId).HasName("PK__STOCK_TR__78E6FD33FAF72D38");

            entity.Property(e => e.TransferId).ValueGeneratedNever();

            entity.HasOne(d => d.ApprovedByNavigation).WithMany(p => p.StockTransferApprovedByNavigations).HasConstraintName("FK_ST_APPROVED_BY");

            entity.HasOne(d => d.FromBranch).WithMany(p => p.StockTransferFromBranches)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ST_FROM_BRANCH");

            entity.HasOne(d => d.RequestedByNavigation).WithMany(p => p.StockTransferRequestedByNavigations)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ST_REQUESTED_BY");

            entity.HasOne(d => d.ToBranch).WithMany(p => p.StockTransferToBranches)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ST_TO_BRANCH");
        });

        modelBuilder.Entity<StockTransferDetail>(entity =>
        {
            entity.HasKey(e => e.TransferDetailId).HasName("PK__STOCK_TR__EC2B8CDB86128AC6");

            entity.Property(e => e.TransferDetailId).ValueGeneratedNever();

            entity.HasOne(d => d.Batch).WithMany(p => p.StockTransferDetails)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_STD_BATCH");

            entity.HasOne(d => d.Medicine).WithMany(p => p.StockTransferDetails)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_STD_MEDICINE");

            entity.HasOne(d => d.Transfer).WithMany(p => p.StockTransferDetails)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_STD_TRANSFER");
        });

        modelBuilder.Entity<Supplier>(entity =>
        {
            entity.HasKey(e => e.SupplierId).HasName("PK__SUPPLIER__6EE594E8CCD9CE8A");

            entity.Property(e => e.SupplierId).ValueGeneratedNever();
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserId).HasName("PK__USER__B9BE370FD5688795");

            entity.Property(e => e.UserId).ValueGeneratedNever();

            entity.HasOne(d => d.Branch).WithMany(p => p.Users).HasConstraintName("FK_USER_BRANCH");

            entity.HasOne(d => d.Role).WithMany(p => p.Users)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_USER_ROLE");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
