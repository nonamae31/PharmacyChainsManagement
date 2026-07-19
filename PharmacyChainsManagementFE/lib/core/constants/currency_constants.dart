abstract final class CurrencyConstants {
  static const String usdSymbol = r'$';
  static const String vndCode = 'VND';
  static const double usdToVndRate = 25000;

  static double convertUsdToVnd(double amountUsd) => amountUsd * usdToVndRate;
}
