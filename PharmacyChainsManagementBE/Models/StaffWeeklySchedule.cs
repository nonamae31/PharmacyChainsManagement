using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("STAFF_WEEKLY_SCHEDULE")]
[Index(nameof(BranchId), nameof(StaffId), Name = "UQ_STAFF_WEEKLY_SCHEDULE_BranchStaff", IsUnique = true)]
public sealed class StaffWeeklySchedule
{
    [Key]
    [Column("weekly_schedule_id")]
    public Guid WeeklyScheduleId { get; set; }

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("staff_id")]
    public Guid StaffId { get; set; }

    [Column("start_time")]
    public TimeOnly StartTime { get; set; }

    [Column("end_time")]
    public TimeOnly EndTime { get; set; }

    [Column("updated_by")]
    public Guid UpdatedBy { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}
