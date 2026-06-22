using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("STOCK_TRANSFER")]
public partial class StockTransfer
{
    [Key]
    [Column("transfer_id")]
    public Guid TransferId { get; set; }

    [Column("from_branch_id")]
    public Guid FromBranchId { get; set; }

    [Column("to_branch_id")]
    public Guid ToBranchId { get; set; }

    [Column("requested_by")]
    public Guid RequestedBy { get; set; }

    [Column("approved_by")]
    public Guid? ApprovedBy { get; set; }

    [Column("transfer_status")]
    [StringLength(30)]
    public string TransferStatus { get; set; } = null!;

    [Column("request_date")]
    public DateOnly RequestDate { get; set; }

    [Column("approved_date")]
    public DateOnly? ApprovedDate { get; set; }

    [Column("notes")]
    public string? Notes { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [ForeignKey("ApprovedBy")]
    [InverseProperty("StockTransferApprovedByNavigations")]
    public virtual User? ApprovedByNavigation { get; set; }

    [ForeignKey("FromBranchId")]
    [InverseProperty("StockTransferFromBranches")]
    public virtual Branch FromBranch { get; set; } = null!;

    [ForeignKey("RequestedBy")]
    [InverseProperty("StockTransferRequestedByNavigations")]
    public virtual User RequestedByNavigation { get; set; } = null!;

    [InverseProperty("Transfer")]
    public virtual ICollection<StockTransferDetail> StockTransferDetails { get; set; } = new List<StockTransferDetail>();

    [ForeignKey("ToBranchId")]
    [InverseProperty("StockTransferToBranches")]
    public virtual Branch ToBranch { get; set; } = null!;
}
