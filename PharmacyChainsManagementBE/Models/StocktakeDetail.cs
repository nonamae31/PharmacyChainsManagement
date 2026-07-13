using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

[Table("STOCKTAKE_DETAIL")]
public partial class StocktakeDetail
{
    [Key]
    [Column("stocktake_detail_id")]
    public Guid StocktakeDetailId { get; set; }

    [Column("stocktake_id")]
    public Guid StocktakeId { get; set; }

    [Column("medicine_id")]
    public Guid MedicineId { get; set; }

    [Column("batch_id")]
    public Guid BatchId { get; set; }

    [Column("system_quantity")]
    public int SystemQuantity { get; set; }

    [Column("physical_quantity")]
    public int PhysicalQuantity { get; set; }

    [ForeignKey("BatchId")]
    [InverseProperty("StocktakeDetails")]
    public virtual MedicineBatch Batch { get; set; } = null!;

    [ForeignKey("MedicineId")]
    [InverseProperty("StocktakeDetails")]
    public virtual Medicine Medicine { get; set; } = null!;

    [ForeignKey("StocktakeId")]
    [InverseProperty("StocktakeDetails")]
    public virtual Stocktake Stocktake { get; set; } = null!;

    [InverseProperty("StocktakeDetail")]
    public virtual ICollection<InventoryAdjustment> InventoryAdjustments { get; set; } = new List<InventoryAdjustment>();
}
