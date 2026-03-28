import 'dart:developer';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

import '../../data/repositories/user_repository_impl.dart';
import '../../data/services/export_service.dart';
import 'analytics_controller.dart';
import 'parameter_controller.dart';

class ProfileController extends GetxController {
  final _userRepo = UserRepositoryImpl();

  late final ExportService exportService;

  var biometricEnabled = false.obs;
  var selectedAvatar = '🧠'.obs;
  var isExporting = false.obs;
  var displayName = 'User'.obs;

  User? get user => FirebaseAuth.instance.currentUser;

  static const avatarEmojis = [
    '🧠','🚀','🌟','💪','🎯','🦁','🔥','⚡',
    '🌿','🏆','🎭','🌈','💎','🦅','🐉','🌙',
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

  // ✅ LOAD DATA
  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final user = this.user;

    biometricEnabled.value = prefs.getBool('biometric_lock') ?? false;
    selectedAvatar.value = prefs.getString('avatar_emoji') ?? '🧠';

    String? localName = prefs.getString('user_name');

    if (localName != null && localName.isNotEmpty) {
      displayName.value = localName;
      return;
    }

    if (user != null) {
      try {
        final userEntity = await _userRepo.getUser(user.uid);
        final name = userEntity?.name;

        String finalName =
            (name != null && name.isNotEmpty)
                ? name
                : (user.displayName ??
                    user.email?.split('@').first ??
                    'User');

        displayName.value = finalName;
        await prefs.setString('user_name', finalName);

      } catch (e) {
        log('Error loading name: $e');
        displayName.value =
            user.displayName ??
            user.email?.split('@').first ??
            'User';
      }
    }
  }

  // ✅ SAVE AVATAR
  Future<void> saveAvatar(String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_emoji', emoji);
    selectedAvatar.value = emoji;
  }

  // ✅ BIOMETRIC
  Future<void> toggleBiometric(bool value) async {
    if (value) {
      try {
        final auth = LocalAuthentication();
        final canCheck = await auth.canCheckBiometrics;

        if (!canCheck) {
          Get.snackbar('Not Available', 'No biometrics enrolled');
          return;
        }

        final authenticated = await auth.authenticate(
          localizedReason: 'Enable biometric lock',
        );

        if (!authenticated) return;

      } on PlatformException {
        Get.snackbar('Error', 'Biometric not supported');
        return;
      } catch (_) {
        Get.snackbar('Error', 'Biometric failed');
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_lock', value);
    biometricEnabled.value = value;
  }

  // ✅ EXPORT CSV
  Future<void> exportCsv() async {
    isExporting.value = true;
    try {
      await exportService.exportCsv();
    } catch (e) {
      Get.snackbar('Export Failed', e.toString());
    } finally {
      isExporting.value = false;
    }
  }

  // ✅ EXPORT PDF
  Future<void> exportPdf() async {
    isExporting.value = true;
    try {
      await exportService.exportPdf();
    } catch (e) {
      Get.snackbar('Export Failed', e.toString());
    } finally {
      isExporting.value = false;
    }
  }

  // ✅ UPDATE NAME
  Future<void> updateName(String newName) async {
    final user = this.user;

    await user?.updateDisplayName(newName);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);

    displayName.value = newName;

    if (user != null) {
      await _userRepo.updateUser(user.uid, {'name': newName});
    }
  }
}