using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("STOCK_TRANSFER_DETAIL")]
public partial class StockTransferDetail
{
    [Key]
    [Column("transfer_detail_id")]
    public Guid TransferDetailId { get; set; }

    [Column("transfer_id")]
    public Guid TransferId { get; set; }

    [Column("medicine_id")]
    public Guid MedicineId { get; set; }

    [Column("batch_id")]
    public Guid BatchId { get; set; }

    [Column("quantity")]
    public int Quantity { get; set; }

    [ForeignKey("BatchId")]
    [InverseProperty("StockTransferDetails")]
    public virtual MedicineBatch Batch { get; set; } = null!;

    [ForeignKey("MedicineId")]
    [InverseProperty("StockTransferDetails")]
    public virtual Medicine Medicine { get; set; } = null!;

    [ForeignKey("TransferId")]
    [InverseProperty("StockTransferDetails")]
    public virtual StockTransfer Transfer { get; set; } = null!;
}
