using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("PAYMENT_GATEWAY")]
[Index("GatewayCode", Name = "UQ__PAYMENT___3AC42EB5324B5E97", IsUnique = true)]
public partial class PaymentGateway
{
    [Key]
    [Column("gateway_id")]
    public short GatewayId { get; set; }

    [Column("gateway_code")]
    [StringLength(50)]
    public string GatewayCode { get; set; } = null!;

    [Column("provider")]
    [StringLength(100)]
    public string Provider { get; set; } = null!;

    [Column("is_active")]
    public bool IsActive { get; set; }

    [InverseProperty("Gateway")]
    public virtual ICollection<PaymentTransaction> PaymentTransactions { get; set; } = new List<PaymentTransaction>();
}
