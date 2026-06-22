using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("MEDICINE")]
public partial class Medicine
{
    [Key]
    [Column("medicine_id")]
    public Guid MedicineId { get; set; }

    [Column("medicine_name")]
    [StringLength(150)]
    public string MedicineName { get; set; } = null!;

    [Column("category")]
    [StringLength(100)]
    public string? Category { get; set; }

    [Column("unit")]
    [StringLength(50)]
    public string Unit { get; set; } = null!;

    [Column("standard_price", TypeName = "decimal(12, 2)")]
    public decimal StandardPrice { get; set; }

    [Column("usage_description")]
    public string? UsageDescription { get; set; }

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [InverseProperty("Medicine")]
    public virtual ICollection<Inventory> Inventories { get; set; } = new List<Inventory>();

    [InverseProperty("Medicine")]
    public virtual ICollection<InvoiceDetail> InvoiceDetails { get; set; } = new List<InvoiceDetail>();

    [InverseProperty("Medicine")]
    public virtual ICollection<MedicineBatch> MedicineBatches { get; set; } = new List<MedicineBatch>();

    [InverseProperty("Medicine")]
    public virtual ICollection<PrescriptionDetail> PrescriptionDetails { get; set; } = new List<PrescriptionDetail>();

    [InverseProperty("Medicine")]
    public virtual ICollection<PurchaseOrderDetail> PurchaseOrderDetails { get; set; } = new List<PurchaseOrderDetail>();

    [InverseProperty("Medicine")]
    public virtual ICollection<StockTransferDetail> StockTransferDetails { get; set; } = new List<StockTransferDetail>();
}
