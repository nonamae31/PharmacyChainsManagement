using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("REPORT")]
public partial class Report
{
    [Key]
    [Column("report_id")]
    public Guid ReportId { get; set; }

    [Column("report_type")]
    [StringLength(50)]
    public string ReportType { get; set; } = null!;

    [Column("from_date")]
    public DateOnly? FromDate { get; set; }

    [Column("to_date")]
    public DateOnly? ToDate { get; set; }

    [Column("generated_by")]
    public Guid GeneratedBy { get; set; }

    [Column("file_uri")]
    [StringLength(255)]
    public string? FileUri { get; set; }

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [ForeignKey("GeneratedBy")]
    [InverseProperty("Reports")]
    public virtual User GeneratedByNavigation { get; set; } = null!;
}
