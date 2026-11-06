import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../data/services/export_file_store.dart';

import '../controllers/analytics_controller.dart';
import '../controllers/parameter_controller.dart';
import 'pdf_report.dart';

class ExportService {
  final AnalyticsController analytics;
  final ParameterController parameters;

  ExportService({required this.analytics, required this.parameters});

  static Future<pw.ThemeData>? _theme;

  /// Fonts ship with the app; fetching them at export time failed offline.
  @visibleForTesting
  static Future<pw.ThemeData> pdfTheme() =>
      _theme ??= _loadTheme().catchError((Object error) {
        _theme = null;
        throw error;
      });

  static Future<pw.ThemeData> _loadTheme() async {
    Future<pw.Font> load(String weight) async => pw.Font.ttf(
      await rootBundle.load('assets/fonts/inter/Inter-$weight.ttf'),
    );
    return pw.ThemeData.withFont(
      base: await load('Regular'),
      bold: await load('Bold'),
    );
  }

  // CSV Export
  Future<void> exportCsv() async {
    final history = analytics.history;
    final habits = parameters.parameters;
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Build rows
    final List<List<dynamic>> rows = [];
    // Header
    rows.add([
      'Date',
      ...habits.map((h) => '${h.name} (${h.isActive ? "Active" : "Inactive"})'),
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

    final file = await ExportFileStore.write(
      'analyzer_export_${dateFormat.format(DateTime.now())}.csv',
      text: toCsv(rows),
    );

    // No email: share text is visible to the receiving app/recipient.
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text:
            'Analyzer — Habit Data Export\n'
            'Exported: ${dateFormat.format(DateTime.now())}',
      ),
    );
  }

  /// Renders the report and hands it to the share sheet.
  Future<void> exportPdf() async {
    final now = DateTime.now();
    final bytes = await PdfReport(
      theme: await pdfTheme(),
      analytics: analytics,
      habits: parameters.parameters,
      user: FirebaseAuth.instance.currentUser,
      now: now,
    ).build();

    final date = DateFormat('yyyy-MM-dd').format(now);
    final file = await ExportFileStore.write(
      'analyzer_report_$date.pdf',
      bytes: bytes,
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        text: 'Analyzer — Full Report\nGenerated: $date',
      ),
    );
  }

  // Helpers
  @visibleForTesting
  static String toCsv(List<List<dynamic>> rows) {
    final buf = StringBuffer();
    for (final row in rows) {
      buf.writeln(row.map((cell) => _csvCell(cell.toString())).join(','));
    }
    return buf.toString();
  }

  static String _csvCell(String value) {
    // Spreadsheets execute cells starting with these as formulas (CSV
    // injection); a leading quote forces them to render as text.
    final safe = RegExp(r'^[=+\-@\t\r]').hasMatch(value) ? "'$value" : value;
    if (RegExp(r'[,"\r\n]').hasMatch(safe)) {
      return '"${safe.replaceAll('"', '""')}"';
    }
    return safe;
  }
}
