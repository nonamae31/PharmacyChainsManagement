using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

[Table("INVENTORY_RECEIPT")]
public partial class InventoryReceipt
{
    [Key]
    [Column("receipt_id")]
    public Guid ReceiptId { get; set; }

    [Column("supplier_id")]
    public Guid SupplierId { get; set; }

    [Column("po_id")]
    public Guid? PoId { get; set; }

    [Column("delivery_note_no")]
    [StringLength(100)]
    public string? DeliveryNoteNo { get; set; }

    [Column("received_date")]
    public DateTime ReceivedDate { get; set; }

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [ForeignKey("SupplierId")]
    [InverseProperty("InventoryReceipts")]
    public virtual Supplier Supplier { get; set; } = null!;

    [ForeignKey("PoId")]
    [InverseProperty("InventoryReceipts")]
    public virtual PurchaseOrder? PurchaseOrder { get; set; }

    [InverseProperty("Receipt")]
    public virtual ICollection<InventoryReceiptDetail> InventoryReceiptDetails { get; set; } = new List<InventoryReceiptDetail>();
}
