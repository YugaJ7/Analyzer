import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

import '../../core/errors/app_exception.dart';
import '../../data/services/preferences_service.dart';
import '../../data/services/export_service.dart';
import '../../domain/repositories/user_repository.dart';
import 'analytics_controller.dart';
import 'parameter_controller.dart';

class ProfileController extends GetxController {
  final UserRepository userRepository;

  ProfileController({required this.userRepository});

  late final ExportService exportService;

  final RxBool biometricEnabled = false.obs;
  final RxString selectedAvatar = '🧠'.obs;
  final RxBool isExporting = false.obs;
  final RxString displayName = 'User'.obs;

  User? get user => FirebaseAuth.instance.currentUser;

  static const avatarEmojis = [
    '🧠', '🚀', '🌟', '💪', '🎯', '🦁', '🔥', '⚡',
    '🌿', '🏆', '🎭', '🌈', '💎', '🦅', '🐉', '🌙',
  ];

  @override
  void onInit() {
    super.onInit();

    final analytics = Get.find<AnalyticsController>();
    final params = Get.find<ParameterController>();

    exportService = ExportService(
      analytics: analytics,
      parameters: params,
    );

    loadPrefs();
  }

  //Load user data
  Future<void> loadPrefs() async {
    final prefs = PreferencesService.instance;
    final currentUser = user;

    biometricEnabled.value = prefs.biometricEnabled;
    selectedAvatar.value = prefs.avatarEmoji;

    final localName = prefs.userName;
    if (localName != null && localName.isNotEmpty) {
      displayName.value = localName;
      return;
    }

    if (currentUser != null) {
      try {
        final userEntity = await userRepository.getUser(currentUser.uid);
        final name = userEntity?.name;

        final finalName = (name != null && name.isNotEmpty)
            ? name
            : (currentUser.displayName ??
                currentUser.email?.split('@').first ??
                'User');

        displayName.value = finalName;
        await prefs.setUserName(finalName);
      } on AppException {
        displayName.value =
            currentUser.displayName ??
            currentUser.email?.split('@').first ??
            'User';
      } catch (_) {
        displayName.value =
            currentUser.displayName ??
            currentUser.email?.split('@').first ??
            'User';
      }
    }
  }

  //  Avatar
  Future<void> saveAvatar(String emoji) async {
    await PreferencesService.instance.setAvatarEmoji(emoji);
    selectedAvatar.value = emoji;
  }

  //Biometric

  Future<void> toggleBiometric(bool value) async {
    if (value) {
      final authenticated = await _tryBiometricAuth();
      if (!authenticated) return;
    }

    await PreferencesService.instance.setBiometricEnabled(value);
    biometricEnabled.value = value;

    Get.snackbar(
      value ? 'Biometric Enabled' : 'Biometric Disabled',
      value
          ? 'App will require authentication on next launch.'
          : 'Biometric lock has been turned off.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<bool> _tryBiometricAuth() async {
    try {
      final auth = LocalAuthentication();

      final isSupported = await auth.isDeviceSupported();
      if (!isSupported) {
        Get.snackbar('Not Supported', 'This device does not support biometrics or screen lock.');
        return false;
      }

      final canCheck = await auth.canCheckBiometrics;
      if (!canCheck) {
        // No biometrics enrolled but device lock (PIN/pattern) may still work
        // — allow if authenticate() returns true
      }

      final authenticated = await auth.authenticate(
        localizedReason: 'Confirm your identity to enable biometric lock',
      );

      if (!authenticated) {
        Get.snackbar('Cancelled', 'Biometric authentication was cancelled.');
      }

      return authenticated;
    } on PlatformException {
      Get.snackbar('Not Supported', 'Biometric authentication is not available on this device.');
      return false;
    } catch (_) {
      Get.snackbar('Error', 'Something went wrong during authentication.');
      return false;
    }
  }

  // Export

  Future<void> exportCsv() async {
    isExporting.value = true;
    try {
      await exportService.exportCsv();
    } on AppException catch (e) {
      Get.snackbar('Export Failed', e.message);
    } catch (e) {
      Get.snackbar('Export Failed', 'Could not export CSV. Please try again.');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportPdf() async {
    isExporting.value = true;
    try {
      await exportService.exportPdf();
    } on AppException catch (e) {
      Get.snackbar('Export Failed', e.message);
    } catch (e) {
      Get.snackbar('Export Failed', 'Could not export PDF. Please try again.');
    } finally {
      isExporting.value = false;
    }
  }

  // Update name

  Future<void> updateName(String newName) async {
    final currentUser = user;

    await currentUser?.updateDisplayName(newName);
    await PreferencesService.instance.setUserName(newName);
    displayName.value = newName;

    if (currentUser != null) {
      try {
        await userRepository.updateUser(currentUser.uid, {'name': newName});
      } on AppException catch (e) {
        Get.snackbar('Sync Error', e.message);
      }
    }
  }
}