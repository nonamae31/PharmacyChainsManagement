using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

[Table("INVENTORY_ADJUSTMENT")]
public partial class InventoryAdjustment
{
    [Key]
    [Column("adjustment_id")]
    public Guid AdjustmentId { get; set; }

    [Column("stocktake_detail_id")]
    public Guid? StocktakeDetailId { get; set; }

    [Column("inventory_id")]
    public Guid InventoryId { get; set; }

    [Column("adjustment_type")]
    [StringLength(30)]
    public string AdjustmentType { get; set; } = null!; // LOSS, GAIN, DAMAGE, EXPIRED

    [Column("quantity")]
    public int Quantity { get; set; }

    [Column("reason")]
    public string? Reason { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [ForeignKey("StocktakeDetailId")]
    [InverseProperty("InventoryAdjustments")]
    public virtual StocktakeDetail? StocktakeDetail { get; set; }

    [ForeignKey("InventoryId")]
    public virtual Inventory Inventory { get; set; } = null!;
}
