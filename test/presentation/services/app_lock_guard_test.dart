import 'dart:async';

import 'package:analyzer/presentation/services/app_lock_guard.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime now;
  late bool lockRequired;
  late int lockShownCount;
  late Completer<void> lockDismissed;
  late AppLockGuard guard;

  setUp(() {
    now = DateTime(2026, 1, 1, 12);
    lockRequired = true;
    lockShownCount = 0;
    lockDismissed = Completer<void>();
    guard = AppLockGuard(
      now: () => now,
      isLockRequired: () => lockRequired,
      showLock: () {
        lockShownCount++;
        return lockDismissed.future;
      },
    );
  });

  void background() =>
      guard.didChangeAppLifecycleState(AppLifecycleState.paused);

  void resumeAfter(Duration elapsed) {
    now = now.add(elapsed);
    guard.didChangeAppLifecycleState(AppLifecycleState.resumed);
  }

  test('locks when resumed after the grace period', () {
    background();
    resumeAfter(AppLockGuard.relockAfter);

    expect(lockShownCount, 1);
  });

  test('does not lock on a quick trip away', () {
    background();
    resumeAfter(AppLockGuard.relockAfter - const Duration(seconds: 1));

    expect(lockShownCount, 0);
  });

  test('does not lock when the lock is not required', () {
    lockRequired = false;

    background();
    resumeAfter(const Duration(minutes: 5));

    expect(lockShownCount, 0);
  });

  test('ignores inactive, which the biometric prompt triggers', () {
    guard.didChangeAppLifecycleState(AppLifecycleState.inactive);
    resumeAfter(const Duration(minutes: 5));

    expect(lockShownCount, 0);
  });

  test('measures from the first background event', () {
    background();
    now = now.add(const Duration(seconds: 20));
    guard.didChangeAppLifecycleState(AppLifecycleState.hidden);
    resumeAfter(const Duration(seconds: 10));

    expect(lockShownCount, 1);
  });

  test('does not stack lock screens while one is showing', () async {
    background();
    resumeAfter(const Duration(minutes: 1));
    background();
    resumeAfter(const Duration(minutes: 1));

    expect(lockShownCount, 1);

    lockDismissed.complete();
    await Future<void>.delayed(Duration.zero);
    lockDismissed = Completer<void>();
    background();
    resumeAfter(const Duration(minutes: 1));

    expect(lockShownCount, 2);
  });
}
