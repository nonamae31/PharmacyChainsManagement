using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

public partial class Invoice
{
    [NotMapped]
    public InvoicePaymentStatus PaymentStatusEnum
    {
        get => Enum.TryParse<InvoicePaymentStatus>(PaymentStatus, true, out var result) ? result : default;
        set => PaymentStatus = value.ToString().ToUpper();
    }

    [NotMapped]
    public InvoiceStatus StatusEnum
    {
        get => Enum.TryParse<InvoiceStatus>(Status, true, out var result) ? result : default;
        set => Status = value.ToString().ToUpper();
    }
}
