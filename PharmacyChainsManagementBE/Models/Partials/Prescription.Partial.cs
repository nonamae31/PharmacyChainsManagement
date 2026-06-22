using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

public partial class Prescription
{
    [NotMapped]
    public PrescriptionStatus StatusEnum
    {
        get => Enum.TryParse<PrescriptionStatus>(Status, true, out var result) ? result : default;
        set => Status = value.ToString().ToUpper();
    }
}
