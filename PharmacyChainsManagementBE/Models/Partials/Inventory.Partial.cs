using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

public partial class Inventory
{
    [NotMapped]
    public GeneralStatus StatusEnum
    {
        get => Enum.TryParse<GeneralStatus>(Status, true, out var result) ? result : default;
        set => Status = value.ToString().ToUpper();
    }
}
