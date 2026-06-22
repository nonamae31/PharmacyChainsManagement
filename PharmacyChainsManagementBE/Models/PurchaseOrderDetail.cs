using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("PURCHASE_ORDER_DETAIL")]
public partial class PurchaseOrderDetail
{
    [Key]
    [Column("po_detail_id")]
    public Guid PoDetailId { get; set; }

    [Column("po_id")]
    public Guid PoId { get; set; }

    [Column("medicine_id")]
    public Guid MedicineId { get; set; }

    [Column("ordered_quantity")]
    public int OrderedQuantity { get; set; }

    [Column("unit_price", TypeName = "decimal(12, 2)")]
    public decimal UnitPrice { get; set; }

    [Column("line_total", TypeName = "decimal(12, 2)")]
    public decimal LineTotal { get; set; }

    [ForeignKey("MedicineId")]
    [InverseProperty("PurchaseOrderDetails")]
    public virtual Medicine Medicine { get; set; } = null!;

    [ForeignKey("PoId")]
    [InverseProperty("PurchaseOrderDetails")]
    public virtual PurchaseOrder Po { get; set; } = null!;
}
