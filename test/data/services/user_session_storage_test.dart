import 'dart:io';

import 'package:analyzer/core/utils/app_constants.dart';
import 'package:analyzer/data/services/export_file_store.dart';
import 'package:analyzer/data/services/hive_service.dart';
import 'package:analyzer/data/services/preferences_service.dart';
import 'package:analyzer/data/services/user_session_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _widgetChannel = MethodChannel('habit_widget_channel');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDir;
  late List<String> widgetCalls;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('user_session_test');
    Hive.init(hiveDir.path);
    await HiveService.init();
    ExportFileStore.baseDirectory = () async => hiveDir;

    SharedPreferences.setMockInitialValues({
      AppConstants.kUserNameKey: 'Previous User',
      AppConstants.kAvatarKey: '🚀',
      '${AppConstants.kAppLockKeyPrefix}_uid-a': true,
      '${AppConstants.kAppLockKeyPrefix}__guest': true,
      AppConstants.kLegacyAppLockKey: true,
    });
    await PreferencesService.init();

    widgetCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_widgetChannel, (call) async {
          widgetCalls.add(call.method);
          return true;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_widgetChannel, null);
    await Hive.deleteFromDisk();
    await hiveDir.delete(recursive: true);
  });

  Future<void> seedUserData() async {
    await HiveService.analyticsBox.put('history', {'2026-01-01': []});
    await HiveService.streakBox.put('param-1', {'current': 3, 'best': 5});
  }

  String? ownerUid() =>
      HiveService.sessionMetaBox.get(AppConstants.kSessionOwnerUidKey)
          as String?;

  group('bindToUser', () {
    test('keeps local data when it already belongs to the same user', () async {
      await HiveService.sessionMetaBox.put(
        AppConstants.kSessionOwnerUidKey,
        'uid-a',
      );
      await seedUserData();

      await UserSessionStorage.bindToUser('uid-a');

      expect(HiveService.analyticsBox.isNotEmpty, isTrue);
      expect(HiveService.streakBox.get('param-1'), isNotNull);
      expect(PreferencesService.instance.userName, 'Previous User');
      expect(widgetCalls, isEmpty);
    });

    test('wipes local data left by a different user', () async {
      await HiveService.sessionMetaBox.put(
        AppConstants.kSessionOwnerUidKey,
        'uid-a',
      );
      await seedUserData();

      await UserSessionStorage.bindToUser('uid-b');

      expect(HiveService.analyticsBox.isEmpty, isTrue);
      expect(HiveService.streakBox.isEmpty, isTrue);
      expect(PreferencesService.instance.userName, isNull);
      expect(
        PreferencesService.instance.avatarEmoji,
        AppConstants.kDefaultAvatar,
      );
      expect(widgetCalls, contains('clearWidgetData'));
      expect(ownerUid(), 'uid-b');
    });

    group('display name', () {
      Future<void> ownedBy(String uid) =>
          HiveService.sessionMetaBox.put(AppConstants.kSessionOwnerUidKey, uid);

      test('keeps a cached name for the same user', () async {
        await ownedBy('uid-a');

        await UserSessionStorage.bindToUser('uid-a', displayName: 'Google');

        expect(PreferencesService.instance.userName, 'Previous User');
      });

      test('replaces the previous user\'s name on a switch', () async {
        await ownedBy('uid-a');

        await UserSessionStorage.bindToUser('uid-b', displayName: 'New User');

        expect(PreferencesService.instance.userName, 'New User');
      });

      test('caches nothing for an empty name', () async {
        await ownedBy('uid-a');

        await UserSessionStorage.bindToUser('uid-b', displayName: '');

        expect(PreferencesService.instance.userName, isNull);
      });
    });

    test('treats data with no recorded owner as foreign', () async {
      await seedUserData();

      await UserSessionStorage.bindToUser('uid-a');

      expect(HiveService.analyticsBox.isEmpty, isTrue);
      expect(HiveService.streakBox.isEmpty, isTrue);
      expect(ownerUid(), 'uid-a');
    });
  });

  group('clear', () {
    test('removes all user-scoped data and the recorded owner', () async {
      await HiveService.sessionMetaBox.put(
        AppConstants.kSessionOwnerUidKey,
        'uid-a',
      );
      await seedUserData();
      final export = await ExportFileStore.write('report.csv', text: 'a');

      await UserSessionStorage.clear();

      expect(HiveService.analyticsBox.isEmpty, isTrue);
      expect(HiveService.streakBox.isEmpty, isTrue);
      expect(PreferencesService.instance.userName, isNull);
      expect(widgetCalls, contains('clearWidgetData'));
      expect(export.existsSync(), isFalse);
      expect(ownerUid(), isNull);
    });

    test('preserves per-uid app-lock preferences', () async {
      await UserSessionStorage.clear();

      expect(
        PreferencesService.instance.getBool(
          '${AppConstants.kAppLockKeyPrefix}_uid-a',
        ),
        isTrue,
      );
    });

    test('removes app-lock keys that belong to no account', () async {
      await UserSessionStorage.clear();

      final prefs = PreferencesService.instance;
      expect(prefs.getBool(AppConstants.kLegacyAppLockKey), isFalse);
      expect(
        prefs.getBool('${AppConstants.kAppLockKeyPrefix}__guest'),
        isFalse,
      );
    });

    test('still clears local storage when the widget channel fails', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_widgetChannel, (call) async {
            throw PlatformException(code: 'widget-error');
          });
      await seedUserData();

      await UserSessionStorage.clear();

      expect(HiveService.analyticsBox.isEmpty, isTrue);
      expect(PreferencesService.instance.userName, isNull);
    });

    test('ignores a missing widget plugin on non-Android platforms', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_widgetChannel, null);
      await seedUserData();

      await expectLater(UserSessionStorage.clear(), completes);
      expect(HiveService.streakBox.isEmpty, isTrue);
    });
  });
}
