using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("MEDICINE_BATCH")]
[Index("MedicineId", "BatchNumber", Name = "UQ_MEDICINE_BATCH_Number", IsUnique = true)]
public partial class MedicineBatch
{
    [Key]
    [Column("batch_id")]
    public Guid BatchId { get; set; }

    [Column("medicine_id")]
    public Guid MedicineId { get; set; }

    [Column("supplier_id")]
    public Guid SupplierId { get; set; }

    [Column("batch_number")]
    [StringLength(100)]
    public string BatchNumber { get; set; } = null!;

    [Column("manufacturing_date")]
    public DateOnly? ManufacturingDate { get; set; }

    [Column("expiry_date")]
    public DateOnly ExpiryDate { get; set; }

    [Column("qc_status")]
    [StringLength(30)]
    public string QcStatus { get; set; } = null!;

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [InverseProperty("Batch")]
    public virtual ICollection<Inventory> Inventories { get; set; } = new List<Inventory>();

    [InverseProperty("Batch")]
    public virtual ICollection<InvoiceDetail> InvoiceDetails { get; set; } = new List<InvoiceDetail>();

    [ForeignKey("MedicineId")]
    [InverseProperty("MedicineBatches")]
    public virtual Medicine Medicine { get; set; } = null!;

    [InverseProperty("Batch")]
    public virtual ICollection<StockTransferDetail> StockTransferDetails { get; set; } = new List<StockTransferDetail>();

    [ForeignKey("SupplierId")]
    [InverseProperty("MedicineBatches")]
    public virtual Supplier Supplier { get; set; } = null!;
}
