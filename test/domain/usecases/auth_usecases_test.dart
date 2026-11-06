import 'package:analyzer/core/errors/app_exception.dart';
import 'package:analyzer/core/errors/failures.dart';
import 'package:analyzer/domain/entities/user_entity.dart';
import 'package:analyzer/domain/repositories/auth_repository.dart';
import 'package:analyzer/domain/repositories/user_repository.dart';
import 'package:analyzer/domain/usecases/register_user.dart';
import 'package:analyzer/domain/usecases/sign_in_with_google.dart';
import 'package:flutter_test/flutter_test.dart';

final _authUser = UserEntity(
  id: 'uid-1',
  email: 'user@example.com',
  name: 'Google Name',
  createdAt: DateTime(2026),
);

const _profileFailure = AppException(ServerFailure('profile write failed'));

class _FakeAuthRepository implements AuthRepository {
  int deleteCalls = 0;
  int logoutCalls = 0;

  @override
  Future<UserEntity> register(String email, String password) async => _authUser;

  @override
  Future<UserEntity> signInWithGoogle() async => _authUser;

  @override
  Future<void> deleteCurrentUser() async => deleteCalls++;

  @override
  Future<void> logout() async => logoutCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({this.stored, this.shouldFail = false});

  final UserEntity? stored;
  final bool shouldFail;
  final created = <String>[];

  @override
  Future<UserEntity> createUser(String id, String email, String name) async {
    if (shouldFail) throw _profileFailure;
    created.add(id);
    return UserEntity(
      id: id,
      email: email,
      name: name,
      createdAt: DateTime(2026),
    );
  }

  @override
  Future<UserEntity> ensureUser(String id, String email, String name) async {
    if (shouldFail) throw _profileFailure;
    return stored ?? await createUser(id, email, name);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('RegisterUser', () {
    test('creates the profile for the new account', () async {
      final auth = _FakeAuthRepository();
      final users = _FakeUserRepository();

      final user = await RegisterUser(auth, users)('a@b.com', 'pass123', 'Ann');

      expect(user.name, 'Ann');
      expect(users.created, ['uid-1']);
      expect(auth.deleteCalls, 0);
    });

    test('rolls back the auth account when profile creation fails', () async {
      final auth = _FakeAuthRepository();
      final users = _FakeUserRepository(shouldFail: true);

      await expectLater(
        RegisterUser(auth, users)('a@b.com', 'pass123', 'Ann'),
        throwsA(same(_profileFailure)),
      );
      expect(auth.deleteCalls, 1);
    });
  });

  group('SignInWithGoogle', () {
    test('creates a profile on first sign-in', () async {
      final users = _FakeUserRepository();

      final user = await SignInWithGoogle(_FakeAuthRepository(), users)();

      expect(users.created, ['uid-1']);
      expect(user.name, 'Google Name');
    });

    test('returns the stored profile so edited names win', () async {
      final stored = _authUser.copyWith(name: 'Edited Name');
      final users = _FakeUserRepository(stored: stored);

      final user = await SignInWithGoogle(_FakeAuthRepository(), users)();

      expect(user.name, 'Edited Name');
      expect(users.created, isEmpty);
    });

    test('signs out when the profile cannot be ensured', () async {
      final auth = _FakeAuthRepository();
      final users = _FakeUserRepository(shouldFail: true);

      await expectLater(
        SignInWithGoogle(auth, users)(),
        throwsA(same(_profileFailure)),
      );
      expect(auth.logoutCalls, 1);
    });
  });
}
