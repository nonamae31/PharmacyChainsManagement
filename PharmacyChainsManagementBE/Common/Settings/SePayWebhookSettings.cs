namespace PharmacyChainsManagementBE.Common.Settings;

public sealed class SePayWebhookSettings
{
    public const string SectionName = "SePayWebhook";

    public string ApiKey { get; set; } = string.Empty;
}
