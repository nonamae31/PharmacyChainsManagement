using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("INVOICE_DETAIL")]
public partial class InvoiceDetail
{
    [Key]
    [Column("invoice_detail_id")]
    public Guid InvoiceDetailId { get; set; }

    [Column("invoice_id")]
    public Guid InvoiceId { get; set; }

    [Column("medicine_id")]
    public Guid MedicineId { get; set; }

    [Column("batch_id")]
    public Guid BatchId { get; set; }

    [Column("quantity")]
    public int Quantity { get; set; }

    [Column("unit_price", TypeName = "decimal(12, 2)")]
    public decimal UnitPrice { get; set; }

    [Column("line_total", TypeName = "decimal(12, 2)")]
    public decimal LineTotal { get; set; }

    [ForeignKey("BatchId")]
    [InverseProperty("InvoiceDetails")]
    public virtual MedicineBatch Batch { get; set; } = null!;

    [ForeignKey("InvoiceId")]
    [InverseProperty("InvoiceDetails")]
    public virtual Invoice Invoice { get; set; } = null!;

    [ForeignKey("MedicineId")]
    [InverseProperty("InvoiceDetails")]
    public virtual Medicine Medicine { get; set; } = null!;
}
