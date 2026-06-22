using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("PAYMENT_TRANSACTION")]
public partial class PaymentTransaction
{
    [Key]
    [Column("payment_id")]
    public Guid PaymentId { get; set; }

    [Column("invoice_id")]
    public Guid InvoiceId { get; set; }

    [Column("gateway_id")]
    public short? GatewayId { get; set; }

    [Column("amount", TypeName = "decimal(12, 2)")]
    public decimal Amount { get; set; }

    [Column("payment_method")]
    [StringLength(50)]
    public string PaymentMethod { get; set; } = null!;

    [Column("payment_status")]
    [StringLength(30)]
    public string PaymentStatus { get; set; } = null!;

    [Column("payment_date")]
    public DateTime? PaymentDate { get; set; }

    [Column("gateway_reference")]
    [StringLength(150)]
    public string? GatewayReference { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [ForeignKey("GatewayId")]
    [InverseProperty("PaymentTransactions")]
    public virtual PaymentGateway? Gateway { get; set; }

    [ForeignKey("InvoiceId")]
    [InverseProperty("PaymentTransactions")]
    public virtual Invoice Invoice { get; set; } = null!;
}
