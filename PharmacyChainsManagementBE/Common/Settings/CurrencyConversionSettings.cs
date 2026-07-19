namespace PharmacyChainsManagementBE.Common.Settings;

public sealed class CurrencyConversionSettings
{
    public const string SectionName = "CurrencyConversion";

    public string BaseCurrency { get; set; } = "USD";
    public string PaymentCurrency { get; set; } = "VND";
    public decimal UsdToVndRate { get; set; }
}
