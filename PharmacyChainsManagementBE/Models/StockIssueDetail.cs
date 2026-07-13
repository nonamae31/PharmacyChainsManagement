using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

[Table("STOCK_ISSUE_DETAIL")]
public partial class StockIssueDetail
{
    [Key]
    [Column("issue_detail_id")]
    public Guid IssueDetailId { get; set; }

    [Column("issue_id")]
    public Guid IssueId { get; set; }

    [Column("medicine_id")]
    public Guid MedicineId { get; set; }

    [Column("batch_id")]
    public Guid BatchId { get; set; }

    [Column("quantity")]
    public int Quantity { get; set; }

    [ForeignKey("BatchId")]
    [InverseProperty("StockIssueDetails")]
    public virtual MedicineBatch Batch { get; set; } = null!;

    [ForeignKey("MedicineId")]
    [InverseProperty("StockIssueDetails")]
    public virtual Medicine Medicine { get; set; } = null!;

    [ForeignKey("IssueId")]
    [InverseProperty("StockIssueDetails")]
    public virtual StockIssue Issue { get; set; } = null!;
}
