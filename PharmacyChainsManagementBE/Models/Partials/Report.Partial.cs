using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

public partial class Report
{
    [NotMapped]
    public ReportStatus StatusEnum
    {
        get => Enum.TryParse<ReportStatus>(Status, true, out var result) ? result : default;
        set => Status = value.ToString().ToUpper();
    }
}
