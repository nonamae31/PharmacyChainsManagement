namespace PharmacyChainsManagementBE.Common.Settings;

public sealed class QrPaymentSettings
{
    public const string SectionName = "QrPayment";

    public string BankBin { get; set; } = string.Empty;
    public string BankName { get; set; } = string.Empty;
    public string AccountNumber { get; set; } = string.Empty;
    public string VirtualAccount { get; set; } = string.Empty;
    public string AccountName { get; set; } = string.Empty;
    public int ExpirationMinutes { get; set; } = 15;
}
