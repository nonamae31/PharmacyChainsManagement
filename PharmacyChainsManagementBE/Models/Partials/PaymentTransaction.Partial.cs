using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

public partial class PaymentTransaction
{
    [NotMapped]
    public PaymentTransactionStatus PaymentStatusEnum
    {
        get => Enum.TryParse<PaymentTransactionStatus>(PaymentStatus, true, out var result) ? result : default;
        set => PaymentStatus = value.ToString().ToUpper();
    }
}
