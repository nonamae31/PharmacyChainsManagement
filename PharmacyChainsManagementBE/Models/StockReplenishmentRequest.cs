using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("STOCK_REPLENISHMENT_REQUEST")]
[Index(nameof(RequestNo), IsUnique = true)]
public sealed class StockReplenishmentRequest
{
    [Key]
    [Column("request_id")]
    public Guid RequestId { get; set; }

    [Column("request_no")]
    [StringLength(50)]
    public string RequestNo { get; set; } = null!;

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("requested_by")]
    public Guid RequestedBy { get; set; }

    [Column("priority")]
    [StringLength(20)]
    public string Priority { get; set; } = null!;

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("notes")]
    [StringLength(500)]
    public string? Notes { get; set; }

    [Column("inventory_note")]
    [StringLength(500)]
    public string? InventoryNote { get; set; }

    [Column("request_date")]
    public DateOnly RequestDate { get; set; }

    [Column("processed_by")]
    public Guid? ProcessedBy { get; set; }

    [Column("processed_at")]
    public DateTime? ProcessedAt { get; set; }

    [Column("transfer_id")]
    public Guid? TransferId { get; set; }

    [Column("dispatched_at")]
    public DateTime? DispatchedAt { get; set; }

    [Column("received_by")]
    public Guid? ReceivedBy { get; set; }

    [Column("received_at")]
    public DateTime? ReceivedAt { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [ForeignKey(nameof(BranchId))]
    public Branch Branch { get; set; } = null!;

    [ForeignKey(nameof(RequestedBy))]
    public User RequestedByNavigation { get; set; } = null!;

    [ForeignKey(nameof(ProcessedBy))]
    public User? ProcessedByNavigation { get; set; }

    [ForeignKey(nameof(TransferId))]
    public StockTransfer? Transfer { get; set; }

    [ForeignKey(nameof(ReceivedBy))]
    public User? ReceivedByNavigation { get; set; }

    public ICollection<StockReplenishmentRequestDetail> Details { get; set; } =
        new List<StockReplenishmentRequestDetail>();
}
