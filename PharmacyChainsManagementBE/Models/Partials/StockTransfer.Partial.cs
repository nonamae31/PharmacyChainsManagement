using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

public partial class StockTransfer
{
    [NotMapped]
    public OrderStatus TransferStatusEnum
    {
        get => Enum.TryParse<OrderStatus>(TransferStatus, true, out var result) ? result : default;
        set => TransferStatus = value.ToString().ToUpper();
    }
}
