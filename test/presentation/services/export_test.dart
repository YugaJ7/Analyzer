import 'dart:io';

import 'package:analyzer/data/services/export_file_store.dart';
import 'package:analyzer/presentation/services/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportService.toCsv', () {
    String cell(String value) => ExportService.toCsv([
      [value],
    ]).trimRight();

    test('neutralises formula-leading cells', () {
      expect(
        cell('=HYPERLINK("http://x","y")'),
        '"\'=HYPERLINK(""http://x"",""y"")"',
      );
      expect(cell('+1'), "'+1");
      expect(cell('-2'), "'-2");
      expect(cell('@SUM(A1)'), "'@SUM(A1)");
      expect(cell('\tx'), "'\tx");
    });

    test('quotes delimiters, quotes and both line endings', () {
      expect(cell('a,b'), '"a,b"');
      expect(cell('say "hi"'), '"say ""hi"""');
      expect(cell('a\nb'), '"a\nb"');
      expect(cell('a\rb'), '"a\rb"');
    });

    test('leaves ordinary values untouched', () {
      expect(cell('Read 20 pages'), 'Read 20 pages');
      expect(cell('✓'), '✓');
      expect(cell('2026-06-15'), '2026-06-15');
    });
  });

  group('ExportFileStore', () {
    late Directory temp;

    setUp(() async {
      temp = await Directory.systemTemp.createTemp('export_store_test');
      ExportFileStore.baseDirectory = () async => temp;
    });

    tearDown(() => temp.delete(recursive: true));

    Future<List<String>> exportNames() async => Directory(
      '${temp.path}/exports',
    ).listSync().map((f) => f.uri.pathSegments.last).toList();

    test('keeps only the latest export', () async {
      await ExportFileStore.write('first.csv', text: 'a');
      final latest = await ExportFileStore.write('second.pdf', bytes: [1, 2]);

      expect(await exportNames(), ['second.pdf']);
      expect(await latest.readAsBytes(), [1, 2]);
    });

    test('clear removes every export', () async {
      await ExportFileStore.write('report.csv', text: 'a');

      await ExportFileStore.clear();

      expect(Directory('${temp.path}/exports').existsSync(), isFalse);
    });

    test('clear is a no-op when nothing was exported', () async {
      await expectLater(ExportFileStore.clear(), completes);
    });
  });
}
