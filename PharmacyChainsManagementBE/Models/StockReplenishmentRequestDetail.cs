using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("STOCK_REPLENISHMENT_REQUEST_DETAIL")]
[Index(nameof(RequestId), nameof(MedicineId), IsUnique = true)]
public sealed class StockReplenishmentRequestDetail
{
    [Key]
    [Column("request_detail_id")]
    public Guid RequestDetailId { get; set; }

    [Column("request_id")]
    public Guid RequestId { get; set; }

    [Column("medicine_id")]
    public Guid MedicineId { get; set; }

    [Column("requested_quantity")]
    public int RequestedQuantity { get; set; }

    [ForeignKey(nameof(RequestId))]
    public StockReplenishmentRequest Request { get; set; } = null!;

    [ForeignKey(nameof(MedicineId))]
    public Medicine Medicine { get; set; } = null!;
}
