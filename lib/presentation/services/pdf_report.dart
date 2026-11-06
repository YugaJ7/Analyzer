import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/date_utils.dart';
import '../../data/models/parameter_model.dart';
import '../../domain/entities/entry_entity.dart';
import '../../domain/entities/parameter_entity.dart';
import '../controllers/analytics_controller.dart';

/// Lays out the full habit report. Pure rendering: everything it shows is
/// passed in, so it never reads controllers or Firebase itself.
class PdfReport {
  PdfReport({
    required this.theme,
    required this.analytics,
    required this.habits,
    required this.user,
    required this.now,
  });

  final pw.ThemeData theme;
  final AnalyticsController analytics;
  final List<ParameterModel> habits;
  final User? user;
  final DateTime now;

  static const _primary = PdfColor(0.424, 0.388, 1.0); // #6C63FF
  static const _accent = PdfColor(0.306, 0.8, 0.769); // #4ECDC4
  static const _card = PdfColor(0.118, 0.153, 0.286); // #1E2749
  static const _streakRed = PdfColor(1.0, 0.420, 0.420);
  static const _gold = PdfColor(1.0, 0.843, 0.0);

  static const _logRowsPerPage = 30;
  // Keeps the report a shareable size; the CSV export has the full log.
  static const _maxLogPages = 3;
  static const _logHabitColumns = 6;
  static const _heatmapDays = 90;

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  Map<DateTime, List<EntryEntity>> get _history => analytics.history;

  Future<Uint8List> build() {
    final pdf = pw.Document()
      ..addPage(_summaryPage())
      ..addPage(_habitsPage())
      ..addPage(_breakdownPage());
    for (final page in _logPages()) {
      pdf.addPage(page);
    }
    return pdf.save();
  }

  pw.Page _page(List<pw.Widget> children) => pw.Page(
    pageFormat: PdfPageFormat.a4,
    theme: theme,
    build: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    ),
  );

  // Summary page

  pw.Page _summaryPage() => _page([
    _header(),
    pw.SizedBox(height: 20),
    _sectionTitle('User Information'),
    pw.SizedBox(height: 8),
    _panel([
      _infoRow(
        'Name',
        user?.displayName ?? user?.email?.split('@').first ?? 'User',
      ),
      _infoRow('Email', user?.email ?? '—'),
      _infoRow('Account ID', user?.uid.substring(0, 12) ?? '—'),
      _infoRow('Report Date', _dateFormat.format(now)),
    ]),
    pw.SizedBox(height: 20),
    _sectionTitle('Analytics Overview'),
    pw.SizedBox(height: 8),
    _overviewStats(),
    pw.SizedBox(height: 20),
    _sectionTitle('This Week'),
    pw.SizedBox(height: 8),
    _weekSummary(),
  ]);

  pw.Widget _header() => pw.Container(
    padding: const pw.EdgeInsets.all(24),
    decoration: pw.BoxDecoration(
      color: _primary,
      borderRadius: pw.BorderRadius.circular(16),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Analyzer — Full Report',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Generated: ${DateFormat('MMMM d, yyyy • h:mm a').format(now)}',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
            ),
          ],
        ),
      ],
    ),
  );

  pw.Widget _overviewStats() {
    final stats = [
      (
        'Performance',
        '${analytics.performanceScore.value.toStringAsFixed(0)}%',
        _primary,
      ),
      (
        'Completion Rate',
        '${analytics.overallCompletionRate.value.toStringAsFixed(0)}%',
        _accent,
      ),
      (
        'Current Streak',
        '${analytics.overallCurrentStreak.value}d',
        _streakRed,
      ),
      ('Best Streak', '${analytics.overallBestStreak.value}d', _gold),
      ('Active Habits', '${analytics.totalActiveHabits.value}', _primary),
    ];
    return pw.Row(
      children: [
        for (final (i, (label, value, color)) in stats.indexed) ...[
          if (i > 0) pw.SizedBox(width: 10),
          _statBox(label, value, color),
        ],
      ],
    );
  }

  pw.Widget _weekSummary() {
    final completed = analytics.weeklyCompleted.value;
    final total = analytics.weeklyTotal.value;
    return _panel([
      _infoRow('Completed', '$completed'),
      _infoRow('Total Possible', '$total'),
      _infoRow(
        'Rate',
        total > 0 ? '${(completed / total * 100).toStringAsFixed(1)}%' : '0%',
      ),
    ]);
  }

  // Habits page

  pw.Page _habitsPage() => _page([
    _sectionTitle('Habit Details'),
    pw.SizedBox(height: 12),
    ...habits.map(_habitCard),
  ]);

  pw.Widget _habitCard(ParameterModel habit) {
    var completedDays = 0;
    var totalDays = 0;
    for (final entries in _history.values) {
      if (entries.isEmpty) continue;
      totalDays++;
      if (entries.any((e) => e.parameterId == habit.id)) completedDays++;
    }
    final rate = totalDays > 0
        ? (completedDays / totalDays * 100).toStringAsFixed(0)
        : '0';

    // A partial pw.Border with borderRadius crashes; use a coloured strip.
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        color: _card,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.ClipRRect(
        horizontalRadius: 12,
        verticalRadius: 12,
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              width: 4,
              color: habit.isActive ? _primary : PdfColors.grey600,
            ),
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(14),
                child: _habitCardBody(habit, completedDays, rate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _habitCardBody(
    ParameterModel habit,
    int completedDays,
    String rate,
  ) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            habit.name,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          _statusBadge(habit.isActive),
        ],
      ),
      if (habit.description != null) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          habit.description!,
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey400),
        ),
      ],
      pw.SizedBox(height: 8),
      pw.Row(
        children: [
          _miniStatBox('Completed Days', '$completedDays', _primary),
          pw.SizedBox(width: 8),
          _miniStatBox('Rate', '$rate%', _accent),
          pw.SizedBox(width: 8),
          _miniStatBox('Type', _habitTypeLabel(habit.type), _primary),
        ],
      ),
    ],
  );

  pw.Widget _statusBadge(bool isActive) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: pw.BoxDecoration(
      color: isActive ? _accent : PdfColors.grey700,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Text(
      isActive ? 'Active' : 'Inactive',
      style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
    ),
  );

  // Breakdown page

  pw.Page _breakdownPage() => _page([
    _sectionTitle('Weekday Breakdown (Historical Average)'),
    pw.SizedBox(height: 12),
    _panel([for (var day = 1; day <= 7; day++) _weekdayBar(day)]),
    pw.SizedBox(height: 24),
    _sectionTitle('Activity Heatmap (Last $_heatmapDays Days)'),
    pw.SizedBox(height: 12),
    _heatmap(),
  ]);

  pw.Widget _weekdayBar(int weekday) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const label = pw.TextStyle(fontSize: 12, color: PdfColors.white);
    final value = analytics.weekdayBreakdown[weekday] ?? 0.0;
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 40,
            child: pw.Text(dayNames[weekday - 1], style: label),
          ),
          pw.Expanded(
            child: pw.ClipRRect(
              horizontalRadius: 4,
              verticalRadius: 4,
              child: pw.LinearProgressIndicator(
                value: value / 100,
                backgroundColor: const PdfColor(0.2, 0.2, 0.3),
                valueColor: _primary,
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text('${value.toStringAsFixed(0)}%', style: label),
        ],
      ),
    );
  }

  pw.Widget _heatmap() {
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          children: [
            for (final day in dayNames)
              pw.Container(
                width: 12,
                height: 12,
                margin: const pw.EdgeInsets.all(1),
                child: pw.Text(
                  day,
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey400,
                  ),
                ),
              ),
          ],
        ),
        pw.SizedBox(width: 2),
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (final week in _heatmapWeeks())
                pw.Column(children: [for (final day in week) _heatCell(day)]),
            ],
          ),
        ),
      ],
    );
  }

  /// Last [_heatmapDays] days as Monday-first week columns; null pads the
  /// days outside the range.
  List<List<DateTime?>> _heatmapWeeks() {
    final weeks = <List<DateTime?>>[];
    var week = List<DateTime?>.filled(7, null);
    for (var i = _heatmapDays - 1; i >= 0; i--) {
      final day = AppDateUtils.addDays(now, -i);
      week[day.weekday - 1] = day;
      if (day.weekday == DateTime.sunday) {
        weeks.add(week);
        week = List<DateTime?>.filled(7, null);
      }
    }
    if (week.any((d) => d != null)) weeks.add(week);
    return weeks;
  }

  pw.Widget _heatCell(DateTime? day) {
    const margin = pw.EdgeInsets.all(0.8);
    if (day == null) {
      return pw.Container(width: 10, height: 10, margin: margin);
    }
    final pct = analytics.heatmapData[day] ?? 0.0;
    final intensity = pct / 100;
    final color = pct == 0
        ? _card
        : PdfColor(
            _primary.red * intensity,
            _primary.green * intensity * 0.8 + 0.3 * intensity,
            1.0 * intensity,
          );
    return pw.Container(
      width: 10,
      height: 10,
      margin: margin,
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(2),
      ),
    );
  }

  // Completion log pages

  Iterable<pw.Page> _logPages() sync* {
    final dates = _history.keys.toList()..sort((a, b) => b.compareTo(a));
    final columns = habits.take(_logHabitColumns).toList();
    for (
      var start = 0, page = 0;
      start < dates.length && page < _maxLogPages;
      start += _logRowsPerPage, page++
    ) {
      final end = (start + _logRowsPerPage).clamp(0, dates.length);
      yield _page([
        _sectionTitle('Completion Log'),
        pw.SizedBox(height: 12),
        _logTable(dates.sublist(start, end), columns),
      ]);
    }
  }

  pw.Widget _logTable(List<DateTime> dates, List<ParameterModel> columns) =>
      pw.Table(
        border: pw.TableBorder.all(
          color: const PdfColor(0.2, 0.2, 0.4),
          width: 0.5,
        ),
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: _primary),
            children: [
              _tableCell('Date', isHeader: true),
              for (final habit in columns)
                _tableCell(
                  habit.name.length > 10
                      ? '${habit.name.substring(0, 10)}…'
                      : habit.name,
                  isHeader: true,
                ),
            ],
          ),
          for (final date in dates)
            pw.TableRow(
              children: [
                _tableCell(_dateFormat.format(date)),
                for (final habit in columns)
                  _tableCell(
                    (_history[date] ?? const <EntryEntity>[]).any(
                          (e) => e.parameterId == habit.id,
                        )
                        ? '✓'
                        : '—',
                  ),
              ],
            ),
        ],
      );

  // Shared pieces

  static pw.Widget _panel(List<pw.Widget> children) => pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: _card,
      borderRadius: pw.BorderRadius.circular(12),
    ),
    child: pw.Column(children: children),
  );

  static pw.Widget _sectionTitle(String title) => pw.Text(
    title,
    style: pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: _primary,
    ),
  );

  static pw.Widget _infoRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey400),
        ),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
        ),
      ],
    ),
  );

  static pw.Widget _statBox(String label, String value, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: pw.BoxDecoration(
            color: _card,
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(color: color, width: 1.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                label,
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey400,
                ),
              ),
            ],
          ),
        ),
      );

  static pw.Widget _miniStatBox(String label, String value, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColor(
              color.red * 0.15,
              color.green * 0.15,
              color.blue * 0.15,
            ),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
              pw.Text(
                label,
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey400,
                ),
              ),
            ],
          ),
        ),
      );

  static pw.Widget _tableCell(String text, {bool isHeader = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHeader ? PdfColors.white : PdfColors.grey200,
          ),
        ),
      );

  static String _habitTypeLabel(ParameterType type) => switch (type) {
    ParameterType.checklist => 'Checklist',
    ParameterType.value => 'Numeric',
    ParameterType.optionSelector => 'Options',
  };
}
