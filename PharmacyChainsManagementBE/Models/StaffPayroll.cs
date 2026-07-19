using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("STAFF_PAYROLL")]
[Index(nameof(BranchId), nameof(StaffId), nameof(PeriodStart), nameof(PeriodEnd), Name = "UQ_STAFF_PAYROLL_BranchStaffPeriod", IsUnique = true)]
public sealed class StaffPayroll
{
    [Key]
    [Column("payroll_id")]
    public Guid PayrollId { get; set; }

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("staff_id")]
    public Guid StaffId { get; set; }

    [Column("period_start")]
    public DateOnly PeriodStart { get; set; }

    [Column("period_end")]
    public DateOnly PeriodEnd { get; set; }

    [Column("hourly_rate", TypeName = "decimal(18, 2)")]
    public decimal HourlyRate { get; set; }

    [Column("completed_hours", TypeName = "decimal(10, 2)")]
    public decimal CompletedHours { get; set; }

    [Column("base_pay", TypeName = "decimal(18, 2)")]
    public decimal BasePay { get; set; }

    [Column("bonus", TypeName = "decimal(18, 2)")]
    public decimal Bonus { get; set; }

    [Column("deduction", TypeName = "decimal(18, 2)")]
    public decimal Deduction { get; set; }

    [Column("net_pay", TypeName = "decimal(18, 2)")]
    public decimal NetPay { get; set; }

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = "DRAFT";

    [Column("notes")]
    [StringLength(500)]
    public string? Notes { get; set; }

    [Column("calculated_by")]
    public Guid CalculatedBy { get; set; }

    [Column("calculated_at")]
    public DateTime CalculatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}
