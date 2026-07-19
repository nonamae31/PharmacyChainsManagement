using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("STAFF_PAY_RATE")]
[Index(nameof(BranchId), nameof(StaffId), Name = "UQ_STAFF_PAY_RATE_BranchStaff", IsUnique = true)]
public sealed class StaffPayRate
{
    [Key]
    [Column("pay_rate_id")]
    public Guid PayRateId { get; set; }

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("staff_id")]
    public Guid StaffId { get; set; }

    [Column("hourly_rate", TypeName = "decimal(18, 2)")]
    public decimal HourlyRate { get; set; }

    [Column("effective_from")]
    public DateOnly EffectiveFrom { get; set; }

    [Column("updated_by")]
    public Guid UpdatedBy { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}
