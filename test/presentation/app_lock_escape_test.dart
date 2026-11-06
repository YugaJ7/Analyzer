import 'package:analyzer/core/utils/app_constants.dart';
import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/data/services/auth_lock_service.dart';
import 'package:analyzer/data/services/preferences_service.dart';
import 'package:analyzer/presentation/screens/auth/splash_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthLockResult.isDeviceLockUnavailable', () {
    test('is true only for failures retrying cannot fix', () {
      const unrecoverable = {
        AuthLockFailure.notSupported,
        AuthLockFailure.noCredentialsSet,
      };

      for (final failure in AuthLockFailure.values) {
        expect(
          AuthLockResult.failure(failure).isDeviceLockUnavailable,
          unrecoverable.contains(failure),
          reason: failure.name,
        );
      }
      expect(const AuthLockResult.success().isDeviceLockUnavailable, isFalse);
    });
  });

  test('disableAppLockFor clears only that account\'s lock', () async {
    const prefix = AppConstants.kAppLockKeyPrefix;
    SharedPreferences.setMockInitialValues({
      '${prefix}_uid-a': true,
      '${prefix}_uid-b': true,
    });
    await PreferencesService.init();

    await PreferencesService.instance.disableAppLockFor('uid-a');

    final prefs = PreferencesService.instance;
    expect(prefs.getBool('${prefix}_uid-a'), isFalse);
    expect(prefs.getBool('${prefix}_uid-b'), isTrue);
  });

  group('AnimatedSplashContent', () {
    Future<void> pumpContent(
      WidgetTester tester, {
      VoidCallback? onSignOut,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnimatedSplashContent(
                isLocked: true,
                onUnlock: () {},
                onSignOut: onSignOut,
              ),
            ),
          ),
        ),
      );
      // Let the entrance animations' delays elapse.
      await tester.pump(const Duration(seconds: 2));
    }

    Future<void> unmount(WidgetTester tester) =>
        tester.pumpWidget(const SizedBox.shrink());

    testWidgets('hides sign-out while unlocking can still work', (
      tester,
    ) async {
      await pumpContent(tester);

      expect(find.text(AppStrings.signOutButton), findsNothing);
      await unmount(tester);
    });

    testWidgets('offers sign-out when the device lock is gone', (tester) async {
      var signedOut = false;
      await pumpContent(tester, onSignOut: () => signedOut = true);

      expect(find.text(AppStrings.deviceLockRemovedMessage), findsOneWidget);
      await tester.tap(find.text(AppStrings.signOutButton));

      expect(signedOut, isTrue);
      await unmount(tester);
    });
  });
}
