import 'package:intl/intl.dart';

/// Formatos de fecha, hora y moneda.
class Fmt {
  static final _time = DateFormat('HH:mm', 'es');
  static final _dayLong = DateFormat("EEEE d 'de' MMMM", 'es');
  static final _dayShort = DateFormat('EEE', 'es');
  static final _dayMonth = DateFormat("d 'de' MMMM", 'es');
  static final _date = DateFormat('dd/MM/yyyy', 'es');
  static final _money = NumberFormat.decimalPattern('es');

  static String time(DateTime d) => _time.format(d);
  static String date(DateTime d) => _date.format(d);
  static String dayLong(DateTime d) => _cap(_dayLong.format(d));
  static String dayMonth(DateTime d) => _dayMonth.format(d);
  static String dayShort(DateTime d) => _cap(_dayShort.format(d).replaceAll('.', ''));
  static String money(int gs) => '₲ ${_money.format(gs)}';
  static String number(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  /// "Hoy", "Mañana", "Ayer" o el día de la semana con fecha.
  static String relativeDay(DateTime d) {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final diff = DateTime(d.year, d.month, d.day).difference(today).inDays;
    return switch (diff) {
      0 => 'Hoy',
      1 => 'Mañana',
      -1 => 'Ayer',
      _ => dayLong(d),
    };
  }

  static String duration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String durationShort(Duration d) {
    if (d.inHours == 0) return '${d.inMinutes} min';
    final m = d.inMinutes % 60;
    return m == 0 ? '${d.inHours} h' : '${d.inHours} h $m min';
  }

  /// "en 35 min", "hace 10 min".
  static String fromNow(DateTime d) {
    final diff = d.difference(DateTime.now());
    final mins = diff.inMinutes.abs();
    final txt = mins < 60 ? '$mins min' : durationShort(Duration(minutes: mins));
    return diff.isNegative ? 'hace $txt' : 'en $txt';
  }

  static String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
