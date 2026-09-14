import 'package:intl/intl.dart';

class AppDateUtils {
  const AppDateUtils._();

  static final _query = DateFormat('yyyy-MM-dd');

  static String display(DateTime value) =>
      DateFormat.yMd(Intl.getCurrentLocale()).format(value.toLocal());
  static String displayDateTime(DateTime value) =>
      DateFormat.yMd(Intl.getCurrentLocale()).add_Hm().format(value.toLocal());
  static String query(DateTime value) => _query.format(value);
  static DateTime? parseQuery(String? value) =>
      value == null ? null : DateTime.tryParse(value);
}
