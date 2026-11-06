/// Calendar-day arithmetic that is safe across DST transitions.
///
/// `Duration(days: n)` is a fixed 24h shift: on a 23h/25h day it lands on the
/// wrong date, breaking map lookups and streak continuity. These helpers work
/// on calendar fields instead.
abstract final class AppDateUtils {
  /// Local midnight of [date].
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime today() => dateOnly(DateTime.now());

  /// Local midnight [days] calendar days from [date] (negative goes back).
  static DateTime addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  /// Whole calendar days from [from] to [to], ignoring time of day.
  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }
}
