using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

public partial class PurchaseOrder
{
    [NotMapped]
    public OrderStatus PoStatusEnum
    {
        get => Enum.TryParse<OrderStatus>(PoStatus, true, out var result) ? result : default;
        set => PoStatus = value.ToString().ToUpper();
    }
}
