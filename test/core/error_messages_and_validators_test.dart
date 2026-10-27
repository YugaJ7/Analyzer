import 'package:analyzer/core/errors/firestore_error_messages.dart';
import 'package:analyzer/core/utils/validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapFirestoreError', () {
    test('maps connectivity codes to a connection message', () {
      for (final code in ['unavailable', 'deadline-exceeded']) {
        expect(
          mapFirestoreError(code, fallback: 'x'),
          contains('Check your connection'),
        );
      }
    });

    test('maps auth codes to a sign-in-again message', () {
      for (final code in ['permission-denied', 'unauthenticated']) {
        expect(mapFirestoreError(code, fallback: 'x'), contains('sign in'));
      }
    });

    test('falls back for unknown codes instead of leaking SDK text', () {
      expect(
        mapFirestoreError('internal', fallback: 'Failed to save.'),
        'Failed to save.',
      );
    });
  });

  group('emailValidator', () {
    test('accepts long TLDs and plus addressing', () {
      expect(emailValidator('a@example.museum'), isNull);
      expect(emailValidator('a+tag@sub.example.technology'), isNull);
    });

    test('rejects malformed addresses', () {
      expect(emailValidator('no-at-sign'), isNotNull);
      expect(emailValidator('a@b'), isNotNull);
      expect(emailValidator(''), isNotNull);
    });
  });

  group('nameValidator', () {
    test('accepts non-ASCII letters, apostrophes and hyphens', () {
      expect(nameValidator("Seán O'Brien"), isNull);
      expect(nameValidator('Jean-Luc'), isNull);
      expect(nameValidator('यश'), isNull);
    });

    test('rejects digits, empty and overlong names', () {
      expect(nameValidator('R2D2'), isNotNull);
      expect(nameValidator('   '), isNotNull);
      expect(nameValidator('a' * 61), isNotNull);
    });
  });

  group('passwordValidator (sign-up)', () {
    test('accepts passphrases with spaces and symbols', () {
      expect(passwordValidator('correct horse 42'), isNull);
    });

    test('requires 8+ chars with a letter and a digit', () {
      expect(passwordValidator('abc123'), isNotNull);
      expect(passwordValidator('abcdefgh'), isNotNull);
      expect(passwordValidator('12345678'), isNotNull);
    });
  });

  test('loginPasswordValidator only requires presence', () {
    expect(loginPasswordValidator('short'), isNull);
    expect(loginPasswordValidator(''), isNotNull);
  });

  test('confirmPasswordValidator requires a match', () {
    expect(confirmPasswordValidator('secret12', 'secret12'), isNull);
    expect(confirmPasswordValidator('secret13', 'secret12'), isNotNull);
    expect(confirmPasswordValidator('', 'secret12'), isNotNull);
  });
}
