using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("PRESCRIPTION")]
public partial class Prescription
{
    [Key]
    [Column("prescription_id")]
    public Guid PrescriptionId { get; set; }

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("staff_id")]
    public Guid StaffId { get; set; }

    [Column("customer_name")]
    [StringLength(150)]
    public string CustomerName { get; set; } = null!;

    [Column("doctor_name")]
    [StringLength(150)]
    public string? DoctorName { get; set; }

    [Column("prescription_date")]
    public DateOnly PrescriptionDate { get; set; }

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [ForeignKey("BranchId")]
    [InverseProperty("Prescriptions")]
    public virtual Branch Branch { get; set; } = null!;

    [InverseProperty("Prescription")]
    public virtual ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();

    [InverseProperty("Prescription")]
    public virtual ICollection<PrescriptionDetail> PrescriptionDetails { get; set; } = new List<PrescriptionDetail>();

    [ForeignKey("StaffId")]
    [InverseProperty("Prescriptions")]
    public virtual User Staff { get; set; } = null!;
}
