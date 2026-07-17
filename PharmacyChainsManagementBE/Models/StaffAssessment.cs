using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("STAFF_ASSESSMENT")]
[Index(nameof(BranchId), nameof(StaffId), nameof(AssessmentDate), Name = "IX_STAFF_ASSESSMENT_BranchStaffDate")]
public sealed class StaffAssessment
{
    [Key]
    [Column("assessment_id")]
    public Guid AssessmentId { get; set; }

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("staff_id")]
    public Guid StaffId { get; set; }

    [Column("assessed_by")]
    public Guid AssessedBy { get; set; }

    [Column("assessment_date")]
    public DateOnly AssessmentDate { get; set; }

    [Column("sales_target", TypeName = "decimal(12, 2)")]
    public decimal SalesTarget { get; set; }

    [Column("customer_rating", TypeName = "decimal(3, 2)")]
    public decimal CustomerRating { get; set; }

    [Column("attendance_percent", TypeName = "decimal(5, 2)")]
    public decimal AttendancePercent { get; set; }

    [Column("performance_score", TypeName = "decimal(5, 2)")]
    public decimal PerformanceScore { get; set; }

    [Column("notes")]
    [StringLength(1000)]
    public string? Notes { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}
