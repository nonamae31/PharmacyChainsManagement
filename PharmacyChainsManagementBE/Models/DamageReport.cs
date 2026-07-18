using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

[Table("DAMAGE_REPORT")]
public partial class DamageReport
{
    [Key]
    [Column("damage_report_id")]
    public Guid DamageReportId { get; set; }

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("medicine_id")]
    public Guid MedicineId { get; set; }

    [Column("batch_id")]
    public Guid BatchId { get; set; }

    [Column("quantity")]
    public int Quantity { get; set; }

    [Column("damage_reason")]
    public string DamageReason { get; set; } = null!;

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!; // PENDING, APPROVED, REJECTED

    [Column("created_by")]
    public Guid CreatedBy { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [ForeignKey("BatchId")]
    [InverseProperty("DamageReports")]
    public virtual MedicineBatch Batch { get; set; } = null!;

    [ForeignKey("MedicineId")]
    [InverseProperty("DamageReports")]
    public virtual Medicine Medicine { get; set; } = null!;

    // Should also probably link to Branch
    [ForeignKey("BranchId")]
    public virtual Branch Branch { get; set; } = null!;
}
