import 'dart:developer';

import 'package:analyzer/core/utils/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserEntity(
        id: credential.user!.uid,
        email: credential.user!.email!,
        name: credential.user!.displayName ?? '',
        createdAt: credential.user!.metadata.creationTime ?? DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw AppException(AuthFailure(mapAuthError(e.code)));
    } catch (e) {
      throw AppException(
        NetworkFailure('Login failed. Check your connection.'),
      );
    }
  }

  @override
  Future<UserEntity> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserEntity(
        id: credential.user!.uid,
        email: credential.user!.email!,
        name: '',
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw AppException(AuthFailure(mapAuthError(e.code)));
    } catch (e) {
      throw AppException(
        NetworkFailure('Registration failed. Check your connection.'),
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw AppException(AuthFailure('Sign-out failed. Please try again.'));
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AppException(const AuthFailure('Google sign-in failed.'));
      }

      return UserEntity(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    } on GoogleSignInException catch (e) {
      // Log the error code only: tokens, emails and raw provider messages
      // are sensitive and must never reach the log.
      _logAuthError('GoogleSignInException(${e.code.name})');
      throw AppException(AuthFailure(_mapGoogleSignInError(e)));
    } on FirebaseAuthException catch (e) {
      _logAuthError('FirebaseAuthException(${e.code})');
      throw AppException(AuthFailure(mapAuthError(e.code)));
    } catch (e, stackTrace) {
      _logAuthError(
        'Unexpected Google sign-in failure: ${e.runtimeType}',
        stackTrace: stackTrace,
      );
      throw AppException(
        NetworkFailure('Google sign-in failed. Please try again.'),
      );
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserEntity(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? '',
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    });
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AppException(const AuthFailure('No authenticated user found.'));
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AppException(AuthFailure(mapAuthError(e.code)));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(NetworkFailure('Password change failed.'));
    }
  }

  /// Debug-only diagnostic logging for auth failures.
  ///
  /// Callers must pass sanitised descriptions (error codes / types only).
  void _logAuthError(String message, {StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    log(message, name: 'AuthRepository', stackTrace: stackTrace);
  }

  /// Maps v7 [GoogleSignInException] error codes to user-friendly messages.
  String _mapGoogleSignInError(GoogleSignInException e) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled =>
        'Google sign-in was cancelled.',
      GoogleSignInExceptionCode.interrupted =>
        'Google sign-in was interrupted. Please try again.',
      GoogleSignInExceptionCode.clientConfigurationError =>
        'Google Sign-In configuration error. Contact support.',
      GoogleSignInExceptionCode.providerConfigurationError =>
        'Google Sign-In is currently unavailable. Try again later.',
      GoogleSignInExceptionCode.uiUnavailable =>
        'Sign-in UI is unavailable on this device.',
      _ => 'Google sign-in failed. Please try again.',
    };
  }
}