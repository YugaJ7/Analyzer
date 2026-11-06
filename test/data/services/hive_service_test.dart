import 'dart:io';

import 'package:analyzer/core/utils/app_constants.dart';
import 'package:analyzer/data/services/hive_service.dart';
import 'package:analyzer/presentation/screens/startup/startup_error_app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDir;
  late Map<String, int> failuresLeft;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('hive_service_test');
    Hive.init(hiveDir.path);
    failuresLeft = {};
    HiveService.openBox = (name) async {
      final left = failuresLeft[name] ?? 0;
      if (left > 0) {
        failuresLeft[name] = left - 1;
        throw HiveError('corrupt box');
      }
      return Hive.openBox<dynamic>(name);
    };
  });

  tearDown(() async {
    HiveService.openBox = Hive.openBox<dynamic>;
    await Hive.deleteFromDisk();
    await hiveDir.delete(recursive: true);
  });

  Future<void> seedAndClose() async {
    await HiveService.init();
    await HiveService.analyticsBox.put('history', {'2026-01-01': []});
    await HiveService.streakBox.put('param-1', {'current': 3});
    await Hive.close();
  }

  group('HiveService.init', () {
    test('opens every box on a clean start', () async {
      await HiveService.init();

      expect(HiveService.analyticsBox.isOpen, isTrue);
      expect(HiveService.streakBox.isOpen, isTrue);
      expect(HiveService.sessionMetaBox.isOpen, isTrue);
    });

    test('resets only the box that fails to open', () async {
      await seedAndClose();
      failuresLeft[AppConstants.kAnalyticsCacheBox] = 1;

      await HiveService.init();

      expect(HiveService.analyticsBox.isEmpty, isTrue);
      expect(HiveService.streakBox.get('param-1'), isNotNull);
    });

    test('rethrows when the box still cannot be opened after reset', () async {
      failuresLeft[AppConstants.kStreakCacheBox] = 2;

      await expectLater(HiveService.init(), throwsA(isA<HiveError>()));
    });
  });

  testWidgets('StartupErrorApp renders without app services', (tester) async {
    await tester.pumpWidget(const StartupErrorApp());

    expect(find.text("Couldn't start the app"), findsOneWidget);
  });
}
