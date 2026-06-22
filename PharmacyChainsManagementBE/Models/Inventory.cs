using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("INVENTORY")]
[Index("BranchId", "BatchId", Name = "UQ_INVENTORY_BranchBatch", IsUnique = true)]
public partial class Inventory
{
    [Key]
    [Column("inventory_id")]
    public Guid InventoryId { get; set; }

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("medicine_id")]
    public Guid MedicineId { get; set; }

    [Column("batch_id")]
    public Guid BatchId { get; set; }

    [Column("quantity_on_hand")]
    public int QuantityOnHand { get; set; }

    [Column("safety_stock_level")]
    public int SafetyStockLevel { get; set; }

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [ForeignKey("BatchId")]
    [InverseProperty("Inventories")]
    public virtual MedicineBatch Batch { get; set; } = null!;

    [ForeignKey("BranchId")]
    [InverseProperty("Inventories")]
    public virtual Branch Branch { get; set; } = null!;

    [ForeignKey("MedicineId")]
    [InverseProperty("Inventories")]
    public virtual Medicine Medicine { get; set; } = null!;
}
