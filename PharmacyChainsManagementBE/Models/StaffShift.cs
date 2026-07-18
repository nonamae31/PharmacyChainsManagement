using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("STAFF_SHIFT")]
[Index(nameof(BranchId), nameof(StaffId), nameof(ShiftDate), Name = "UQ_STAFF_SHIFT_BranchStaffDate", IsUnique = true)]
public sealed class StaffShift
{
    [Key]
    [Column("shift_id")]
    public Guid ShiftId { get; set; }

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("staff_id")]
    public Guid StaffId { get; set; }

    [Column("shift_date")]
    public DateOnly ShiftDate { get; set; }

    [Column("start_time")]
    public TimeOnly StartTime { get; set; }

    [Column("end_time")]
    public TimeOnly EndTime { get; set; }

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("notes")]
    [StringLength(500)]
    public string? Notes { get; set; }

    [Column("created_by")]
    public Guid CreatedBy { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}
