using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

[Table("BUDGET_ALLOCATION")]
public class BudgetAllocation
{
    [Key]
    [Column("allocation_id")]
    public Guid AllocationId { get; set; } = Guid.NewGuid();

    [Column("category_name")]
    [StringLength(100)]
    public string CategoryName { get; set; } = null!;

    [Column("percentage", TypeName = "decimal(5, 2)")]
    public decimal Percentage { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
