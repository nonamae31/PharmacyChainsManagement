using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

[Table("INVENTORY_RECEIPT_DETAIL")]
public partial class InventoryReceiptDetail
{
    [Key]
    [Column("receipt_detail_id")]
    public Guid ReceiptDetailId { get; set; }

    [Column("receipt_id")]
    public Guid ReceiptId { get; set; }

    [Column("medicine_id")]
    public Guid MedicineId { get; set; }

    [Column("batch_id")]
    public Guid BatchId { get; set; }

    [Column("quantity")]
    public int Quantity { get; set; }

    [ForeignKey("BatchId")]
    [InverseProperty("InventoryReceiptDetails")]
    public virtual MedicineBatch Batch { get; set; } = null!;

    [ForeignKey("MedicineId")]
    [InverseProperty("InventoryReceiptDetails")]
    public virtual Medicine Medicine { get; set; } = null!;

    [ForeignKey("ReceiptId")]
    [InverseProperty("InventoryReceiptDetails")]
    public virtual InventoryReceipt Receipt { get; set; } = null!;
}
