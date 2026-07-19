using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("STAFF_ATTENDANCE")]
[Index(nameof(StaffId), nameof(AttendanceDate), Name = "UQ_STAFF_ATTENDANCE_StaffDate", IsUnique = true)]
[Index(nameof(BranchId), nameof(AttendanceDate), Name = "IX_STAFF_ATTENDANCE_BranchDate")]
public sealed class StaffAttendance
{
    [Key]
    [Column("attendance_id")]
    public Guid AttendanceId { get; set; }

    [Column("staff_id")]
    public Guid StaffId { get; set; }

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("attendance_date")]
    public DateOnly AttendanceDate { get; set; }

    [Column("check_in_time")]
    public DateTime CheckInTime { get; set; }

    [Column("check_out_time")]
    public DateTime? CheckOutTime { get; set; }

    [Column("status")]
    [StringLength(20)]
    public string Status { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}
