import 'package:intl/intl.dart';

class CurrencyUtils {
  const CurrencyUtils._();

  static String format(num value) => NumberFormat.currency(
    locale: Intl.getCurrentLocale(),
    symbol: '₫',
    decimalDigits: 0,
  ).format(value);
}
