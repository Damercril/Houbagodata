import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  static final _compactFormatter = NumberFormat.compact(
    locale: 'fr_FR',
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatCompact(double amount) {
    return "${_compactFormatter.format(amount)} FCFA";
  }

  static String formatCurrency(double amount) {
    return _formatter.format(amount);
  }

  static String formatFCFA(double amount) {
    return _formatter.format(amount);
  }
}
