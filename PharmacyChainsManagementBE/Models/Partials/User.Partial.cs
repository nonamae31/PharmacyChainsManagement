using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

public partial class User
{
    [NotMapped]
    public GeneralStatus StatusEnum
    {
        get => Enum.TryParse<GeneralStatus>(Status, true, out var result) ? result : default;
        set => Status = value.ToString().ToUpper();
    }

    public int AccessFailedCount { get; set; }
    public DateTime? LockoutEnd { get; set; }

    public string? PasswordResetToken { get; set; }
    public DateTime? ResetTokenExpiry { get; set; }
}
