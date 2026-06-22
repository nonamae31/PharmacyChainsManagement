using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("PURCHASE_ORDER")]
public partial class PurchaseOrder
{
    [Key]
    [Column("po_id")]
    public Guid PoId { get; set; }

    [Column("supplier_id")]
    public Guid SupplierId { get; set; }

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("created_by")]
    public Guid CreatedBy { get; set; }

    [Column("approved_by")]
    public Guid? ApprovedBy { get; set; }

    [Column("po_status")]
    [StringLength(30)]
    public string PoStatus { get; set; } = null!;

    [Column("order_date")]
    public DateOnly OrderDate { get; set; }

    [Column("expected_date")]
    public DateOnly? ExpectedDate { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [ForeignKey("ApprovedBy")]
    [InverseProperty("PurchaseOrderApprovedByNavigations")]
    public virtual User? ApprovedByNavigation { get; set; }

    [ForeignKey("BranchId")]
    [InverseProperty("PurchaseOrders")]
    public virtual Branch Branch { get; set; } = null!;

    [ForeignKey("CreatedBy")]
    [InverseProperty("PurchaseOrderCreatedByNavigations")]
    public virtual User CreatedByNavigation { get; set; } = null!;

    [InverseProperty("Po")]
    public virtual ICollection<PurchaseOrderDetail> PurchaseOrderDetails { get; set; } = new List<PurchaseOrderDetail>();

    [ForeignKey("SupplierId")]
    [InverseProperty("PurchaseOrders")]
    public virtual Supplier Supplier { get; set; } = null!;
}
