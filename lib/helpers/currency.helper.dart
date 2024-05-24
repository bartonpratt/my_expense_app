import 'package:intl/intl.dart';

class CurrencyHelper {
  static String format(
      double amount, {
        String? symbol = "₵", // Symbol for Ghanaian Cedi
        String? name = "GHS", // Currency code for Ghanaian Cedi
        String? locale = "en_GH", // Locale for Ghanaian Cedi
      }) {
    return NumberFormat.currency(symbol: symbol, name: name, locale: locale).format(amount);
  }

  static String formatCompact(
      double amount, {
        String? symbol = "₵", // Symbol for Ghanaian Cedi
        String? name = "GHS", // Currency code for Ghanaian Cedi
        String? locale = "en_GH", // Locale for Ghanaian Cedi
      }) {
    return NumberFormat.compactCurrency(symbol: symbol, name: name, locale: locale).format(amount);
  }
}
