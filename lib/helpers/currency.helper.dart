import 'package:intl/intl.dart';

class CurrencyHelper {
  static String format(
      double amount, {
        String? symbol = "\$",
        String? name = "USD",
        String? locale = "en_US",
      }) {
    return NumberFormat.currency(symbol: symbol, name: name, locale: locale).format(amount);
  }

  static String formatCompact(double amount, {
    String? symbol = "\$",
    String? name = "USD",
    String? locale = "en_US",
  }) {
    return NumberFormat.compactCurrency(symbol: symbol, name: name, locale: locale).format(amount);
  }
}
