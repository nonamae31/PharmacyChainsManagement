using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

public partial class MedicineBatch
{
    [NotMapped]
    public QcStatus QcStatusEnum
    {
        get => Enum.TryParse<QcStatus>(QcStatus, true, out var result) ? result : default;
        set => QcStatus = value.ToString().ToUpper();
    }

    [NotMapped]
    public GeneralStatus StatusEnum
    {
        get => Enum.TryParse<GeneralStatus>(Status, true, out var result) ? result : default;
        set => Status = value.ToString().ToUpper();
    }
}
