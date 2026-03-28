import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' show PdfGoogleFonts;
import 'package:share_plus/share_plus.dart';

import '../../../presentation/controllers/analytics_controller.dart';
import '../../../presentation/controllers/parameter_controller.dart';

class ExportService {
  final AnalyticsController analytics;
  final ParameterController parameters;

  ExportService({required this.analytics, required this.parameters});

  // CSV Export
  Future<void> exportCsv() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final history = analytics.history;
      final habits = parameters.parameters;
      final dateFormat = DateFormat('yyyy-MM-dd');

      // Build rows
      final List<List<dynamic>> rows = [];
      // Header
      rows.add([
        'Date',
        ...habits.map(
          (h) => '${h.name} (${h.isActive ? "Active" : "Inactive"})',
        ),
      ]);

      // Sort dates
      final dates = history.keys.toList()..sort((a, b) => b.compareTo(a));
      for (final date in dates) {
        final entries = history[date] ?? [];
        rows.add([
          dateFormat.format(date),
          ...habits.map((h) {
            final matched = entries.any((e) => e.parameterId == h.id);
            return matched ? '✓' : '';
          }),
        ]);
      }

      final csvData = _toCsv(rows);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/analyzer_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(csvData);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              'Analyzer — Habit Data Export\n'
              'User: ${user?.email ?? "Unknown"}\n'
              'Exported: ${dateFormat.format(DateTime.now())}',
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  // PDF Export — Full Report
  Future<void> exportPdf() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final habits = parameters.parameters;
      final history = analytics.history;
      final dateFormat = DateFormat('yyyy-MM-dd');
      final now = DateTime.now();

      final pdf = pw.Document();

      // Color palette
      const primaryColor = PdfColor(0.424, 0.388, 1.0); // #6C63FF
      const accentColor = PdfColor(0.306, 0.8, 0.769); // #4ECDC4
      const bgColor = PdfColor(0.063, 0.055, 0.153); // #101027
      const cardColor = PdfColor(0.118, 0.153, 0.286); // #1E2749

      // ── Page 1: Summary ─────────────────────────────────
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: await PdfGoogleFonts.interRegular(),
            bold: await PdfGoogleFonts.interBold(),
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(24),
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
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
                            style: const pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // User Info
                _sectionTitle('User Information', primaryColor),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: cardColor,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    children: [
                      _infoRow(
                        'Name',
                        user?.displayName ??
                            user?.email?.split('@').first ??
                            'User',
                      ),
                      _infoRow('Email', user?.email ?? '—'),
                      _infoRow('Account ID', user?.uid.substring(0, 12) ?? '—'),
                      _infoRow('Report Date', dateFormat.format(now)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Analytics Summary
                _sectionTitle('Analytics Overview', primaryColor),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    _statBox(
                      'Performance',
                      '${analytics.performanceScore.value.toStringAsFixed(0)}%',
                      primaryColor,
                    ),
                    pw.SizedBox(width: 10),
                    _statBox(
                      'Completion Rate',
                      '${analytics.overallCompletionRate.value.toStringAsFixed(0)}%',
                      accentColor,
                    ),
                    pw.SizedBox(width: 10),
                    _statBox(
                      'Current Streak',
                      '${analytics.overallCurrentStreak.value}d',
                      PdfColor(1.0, 0.420, 0.420),
                    ),
                    pw.SizedBox(width: 10),
                    _statBox(
                      'Best Streak',
                      '${analytics.overallBestStreak.value}d',
                      PdfColor(1.0, 0.843, 0.0),
                    ),
                    pw.SizedBox(width: 10),
                    _statBox(
                      'Active Habits',
                      '${analytics.totalActiveHabits.value}',
                      primaryColor,
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Weekly Summary
                _sectionTitle('This Week', primaryColor),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: cardColor,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    children: [
                      _infoRow(
                        'Completed',
                        '${analytics.weeklyCompleted.value}',
                      ),
                      _infoRow(
                        'Total Possible',
                        '${analytics.weeklyTotal.value}',
                      ),
                      _infoRow(
                        'Rate',
                        analytics.weeklyTotal.value > 0
                            ? '${(analytics.weeklyCompleted.value / analytics.weeklyTotal.value * 100).toStringAsFixed(1)}%'
                            : '0%',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // ── Page 2: Habit Details ─────────────────────────────────
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: await PdfGoogleFonts.interRegular(),
            bold: await PdfGoogleFonts.interBold(),
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('Habit Details', primaryColor),
                pw.SizedBox(height: 12),
                ...habits.map((habit) {
                  // Compute habit-specific stats
                  int completedDays = 0;
                  int totalDays = 0;
                  for (final entry in history.entries) {
                    final entries = entry.value;
                    if (entries.isNotEmpty) {
                      totalDays++;
                      if (entries.any((e) => e.parameterId == habit.id)) {
                        completedDays++;
                      }
                    }
                  }
                  final rate = totalDays > 0
                      ? (completedDays / totalDays * 100).toStringAsFixed(0)
                      : '0';

                  // pw.Border partial + borderRadius crash fix:
                  // use a Row with a coloured left strip
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 10),
                    decoration: pw.BoxDecoration(
                      color: cardColor,
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.ClipRRect(
                      horizontalRadius: 12,
                      verticalRadius: 12,
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          // Left-coloured strip
                          pw.Container(
                            width: 4,
                            color: habit.isActive
                                ? primaryColor
                                : PdfColors.grey600,
                          ),
                          pw.Expanded(
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.all(14),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        habit.name,
                                        style: pw.TextStyle(
                                          fontSize: 14,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.white,
                                        ),
                                      ),
                                      pw.Container(
                                        padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: pw.BoxDecoration(
                                          color: habit.isActive
                                              ? PdfColor(0.306, 0.8, 0.769)
                                              : PdfColors.grey700,
                                          borderRadius:
                                              pw.BorderRadius.circular(8),
                                        ),
                                        child: pw.Text(
                                          habit.isActive
                                              ? 'Active'
                                              : 'Inactive',
                                          style: const pw.TextStyle(
                                            fontSize: 10,
                                            color: PdfColors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (habit.description != null) ...[
                                    pw.SizedBox(height: 4),
                                    pw.Text(
                                      habit.description!,
                                      style: const pw.TextStyle(
                                        fontSize: 11,
                                        color: PdfColors.grey400,
                                      ),
                                    ),
                                  ],
                                  pw.SizedBox(height: 8),
                                  pw.Row(
                                    children: [
                                      _miniStatBox(
                                        'Completed Days',
                                        '$completedDays',
                                        primaryColor,
                                      ),
                                      pw.SizedBox(width: 8),
                                      _miniStatBox(
                                        'Rate',
                                        '$rate%',
                                        accentColor,
                                      ),
                                      pw.SizedBox(width: 8),
                                      _miniStatBox(
                                        'Type',
                                        _habitTypeLabel(habit.type.index),
                                        primaryColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      );

      // ── Page 3: Weekday Breakdown ─────────────────────────────────
      final weekdayData = analytics.weekdayBreakdown;
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: await PdfGoogleFonts.interRegular(),
            bold: await PdfGoogleFonts.interBold(),
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  'Weekday Breakdown (Historical Average)',
                  primaryColor,
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: cardColor,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    children: List.generate(7, (i) {
                      final val = weekdayData[i + 1] ?? 0.0;
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Row(
                          children: [
                            pw.SizedBox(
                              width: 40,
                              child: pw.Text(
                                dayNames[i],
                                style: const pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.ClipRRect(
                                horizontalRadius: 4,
                                verticalRadius: 4,
                                child: pw.LinearProgressIndicator(
                                  value: val / 100,
                                  backgroundColor: PdfColor(0.2, 0.2, 0.3),
                                  valueColor: primaryColor,
                                ),
                              ),
                            ),
                            pw.SizedBox(width: 8),
                            pw.Text(
                              '${val.toStringAsFixed(0)}%',
                              style: const pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                pw.SizedBox(height: 24),

                _sectionTitle('Activity Heatmap (Last 90 Days)', primaryColor),
                pw.SizedBox(height: 12),
                _buildHeatmapTable(
                  analytics.heatmapData,
                  bgColor,
                  primaryColor,
                ),
              ],
            );
          },
        ),
      );

      // ── Page 4: Full Completion Log ─────────────────────────────────
      final sortedDates = history.keys.toList()..sort((a, b) => b.compareTo(a));
      const rowsPerPage = 30;
      final chunks = <List<DateTime>>[];
      for (var i = 0; i < sortedDates.length; i += rowsPerPage) {
        chunks.add(
          sortedDates.sublist(
            i,
            i + rowsPerPage > sortedDates.length
                ? sortedDates.length
                : i + rowsPerPage,
          ),
        );
      }

      for (final chunk in chunks.take(3)) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            theme: pw.ThemeData.withFont(
              base: await PdfGoogleFonts.interRegular(),
              bold: await PdfGoogleFonts.interBold(),
            ),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Completion Log', primaryColor),
                  pw.SizedBox(height: 12),
                  pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColor(0.2, 0.2, 0.4),
                      width: 0.5,
                    ),
                    children: [
                      // Header row
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: primaryColor),
                        children: [
                          _tableCell('Date', isHeader: true),
                          ...habits
                              .take(6)
                              .map(
                                (h) => _tableCell(
                                  h.name.length > 10
                                      ? '${h.name.substring(0, 10)}…'
                                      : h.name,
                                  isHeader: true,
                                ),
                              ),
                        ],
                      ),
                      // Data rows
                      ...chunk.map((date) {
                        final entries = history[date] ?? [];
                        return pw.TableRow(
                          children: [
                            _tableCell(dateFormat.format(date)),
                            ...habits.take(6).map((h) {
                              final done = entries.any(
                                (e) => e.parameterId == h.id,
                              );
                              return _tableCell(done ? '✓' : '—');
                            }),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }

      // Share — save to temp file and use SharePlus
      final pdfBytes = await pdf.save();
      final dir = await getTemporaryDirectory();
      final filename =
          'analyzer_report_${DateFormat('yyyy-MM-dd').format(now)}.pdf';
      final pdfFile = File('${dir.path}/$filename');
      await pdfFile.writeAsBytes(pdfBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(pdfFile.path, mimeType: 'application/pdf')],
          text:
              'Analyzer — Full Report\n'
              'User: ${user?.email ?? "Unknown"}\n'
              'Generated: ${DateFormat('yyyy-MM-dd').format(now)}',
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Helpers
  static String _toCsv(List<List<dynamic>> rows) {
    final buf = StringBuffer();
    for (final row in rows) {
      final cells = row.map((cell) {
        final s = cell.toString();
        if (s.contains(',') || s.contains('"') || s.contains('\n')) {
          final escaped = s.replaceAll('"', '""');
          return '"$escaped"';
        }
        return s;
      });
      buf.writeln(cells.join(','));
    }
    return buf.toString();
  }

  static pw.Widget _sectionTitle(String title, PdfColor color) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: color,
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
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
  }

  static pw.Widget _statBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: pw.BoxDecoration(
          color: PdfColor(0.118, 0.153, 0.286),
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
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _miniStatBox(String label, String value, PdfColor color) {
    return pw.Expanded(
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
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
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
  }

  static pw.Widget _buildHeatmapTable(
    Map<DateTime, double> heatmapData,
    PdfColor bgColor,
    PdfColor primaryColor,
  ) {
    final now = DateTime.now();
    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    // Get last 90 days
    final days = List.generate(90, (i) {
      final d = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 89 - i));
      return d;
    });

    // Organize into columns (weeks)
    final columns = <List<DateTime?>>[];
    List<DateTime?> currentCol = List.filled(7, null);
    for (final day in days) {
      final wd = day.weekday - 1; // 0=Mon
      currentCol[wd] = day;
      if (wd == 6) {
        columns.add(List.from(currentCol));
        currentCol = List.filled(7, null);
      }
    }
    if (currentCol.any((d) => d != null)) {
      columns.add(currentCol);
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Day labels
        pw.Column(
          children: dayNames.map((d) {
            return pw.Container(
              width: 12,
              height: 12,
              margin: const pw.EdgeInsets.all(1),
              child: pw.Text(
                d,
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: PdfColors.grey400,
                ),
              ),
            );
          }).toList(),
        ),
        pw.SizedBox(width: 2),
        // Cells
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: columns.map((col) {
              return pw.Column(
                children: col.map((day) {
                  if (day == null) {
                    return pw.Container(
                      width: 10,
                      height: 10,
                      margin: const pw.EdgeInsets.all(0.8),
                    );
                  }
                  final pct = heatmapData[day] ?? 0.0;
                  final intensity = pct / 100;
                  final color = pct == 0
                      ? PdfColor(0.118, 0.153, 0.286)
                      : PdfColor(
                          primaryColor.red * intensity,
                          primaryColor.green * intensity * 0.8 +
                              0.3 * intensity,
                          1.0 * intensity,
                        );
                  return pw.Container(
                    width: 10,
                    height: 10,
                    margin: const pw.EdgeInsets.all(0.8),
                    decoration: pw.BoxDecoration(
                      color: color,
                      borderRadius: pw.BorderRadius.circular(2),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  static String _habitTypeLabel(int typeIndex) {
    switch (typeIndex) {
      case 0:
        return 'Checklist';
      case 1:
        return 'Numeric';
      case 2:
        return 'Options';
      default:
        return 'Unknown';
    }
  }
}
