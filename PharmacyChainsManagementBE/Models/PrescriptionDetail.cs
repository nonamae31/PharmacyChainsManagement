using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("PRESCRIPTION_DETAIL")]
public partial class PrescriptionDetail
{
    [Key]
    [Column("prescription_detail_id")]
    public Guid PrescriptionDetailId { get; set; }

    [Column("prescription_id")]
    public Guid PrescriptionId { get; set; }

    [Column("medicine_id")]
    public Guid MedicineId { get; set; }

    [Column("dosage")]
    [StringLength(100)]
    public string? Dosage { get; set; }

    [Column("frequency")]
    [StringLength(100)]
    public string? Frequency { get; set; }

    [Column("duration")]
    [StringLength(100)]
    public string? Duration { get; set; }

    [Column("quantity")]
    public int Quantity { get; set; }

    [ForeignKey("MedicineId")]
    [InverseProperty("PrescriptionDetails")]
    public virtual Medicine Medicine { get; set; } = null!;

    [ForeignKey("PrescriptionId")]
    [InverseProperty("PrescriptionDetails")]
    public virtual Prescription Prescription { get; set; } = null!;
}
