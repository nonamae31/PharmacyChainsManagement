using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

[Table("STOCKTAKE")]
public partial class Stocktake
{
    [Key]
    [Column("stocktake_id")]
    public Guid StocktakeId { get; set; }

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("created_by")]
    public Guid CreatedBy { get; set; }

    [Column("stocktake_date")]
    public DateTime StocktakeDate { get; set; }

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("notes")]
    public string? Notes { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [ForeignKey("BranchId")]
    [InverseProperty("Stocktakes")]
    public virtual Branch Branch { get; set; } = null!;

    [InverseProperty("Stocktake")]
    public virtual ICollection<StocktakeDetail> StocktakeDetails { get; set; } = new List<StocktakeDetail>();
}
