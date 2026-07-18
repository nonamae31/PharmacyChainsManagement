using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

[Table("STOCK_ISSUE")]
public partial class StockIssue
{
    [Key]
    [Column("issue_id")]
    public Guid IssueId { get; set; }

    [Column("request_no")]
    [StringLength(50)]
    public string RequestNo { get; set; } = null!;

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("issue_date")]
    public DateTime IssueDate { get; set; }

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [ForeignKey("BranchId")]
    [InverseProperty("StockIssues")]
    public virtual Branch Branch { get; set; } = null!;

    [InverseProperty("Issue")]
    public virtual ICollection<StockIssueDetail> StockIssueDetails { get; set; } = new List<StockIssueDetail>();
}
