namespace PharmacyChainsManagementBE.Services;

public class FounderSettings
{
    public const string SectionName = "FounderSettings";

    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
}
