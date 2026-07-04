import '../core/extensions/datetime_ext.dart';

class DateFormatter {
  static String relative(DateTime dt) => dt.relative;
  static String short(DateTime dt) =>
      '${dt.year.toString().substring(2)}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
  static String time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  static String full(DateTime dt) => '${short(dt)} ${time(dt)}';
  static String friendly(DateTime dt) => '${dt.relative} · ${time(dt)}';
}
