import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/app_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../core/bindings/home_binding.dart';
import '../../data/services/auth_lock_service.dart';
import '../services/export_service.dart';
import '../../data/services/preferences_service.dart';
import '../../data/services/user_session_storage.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/logout_user.dart';
import 'analytics_controller.dart';
import 'parameter_controller.dart';

class ProfileController extends GetxController {
  final UserRepository userRepository;
  final LogoutUser logoutUser;

  ProfileController({required this.userRepository, required this.logoutUser});

  late final ExportService exportService;

  final RxBool appLockEnabled = false.obs;
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

    exportService = ExportService(analytics: analytics, parameters: params);

    loadPrefs();
  }

  // 🔥 LOAD PREFS
  Future<void> loadPrefs() async {
    final prefs = PreferencesService.instance;
    final currentUser = user;

    appLockEnabled.value = prefs.appLockEnabled;
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

  // 🔥 AVATAR
  Future<void> saveAvatar(String emoji) async {
    await PreferencesService.instance.setAvatarEmoji(emoji);
    selectedAvatar.value = emoji;
  }

  // Both directions need auth, or anyone holding the unlocked phone could
  // switch the lock off.
  Future<void> toggleAppLock(bool value) async {
    final result = await AuthLockService.instance.authenticate();
    if (!result.isAuthenticated) return;

    await PreferencesService.instance.setAppLockEnabled(value);
    appLockEnabled.value = value;

    Get.snackbar(
      value ? 'App Lock Enabled' : 'App Lock Disabled',
      value
          ? 'App will require authentication on launch.'
          : 'App lock has been turned off.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // 🔥 EXPORT CSV
  Future<void> exportCsv() async {
    isExporting.value = true;
    try {
      await exportService.exportCsv();
    } on AppException catch (e) {
      Get.snackbar('Export Failed', e.message);
    } catch (_) {
      Get.snackbar(
        'Export Failed',
        'Could not export CSV. Please try again.',
      );
    } finally {
      isExporting.value = false;
    }
  }

  // 🔥 EXPORT PDF
  Future<void> exportPdf() async {
    isExporting.value = true;
    try {
      await exportService.exportPdf();
    } on AppException catch (e) {
      Get.snackbar('Export Failed', e.message);
    } catch (_) {
      Get.snackbar(
        'Export Failed',
        'Could not export PDF. Please try again.',
      );
    } finally {
      isExporting.value = false;
    }
  }

  // 🔥 UPDATE NAME
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

  /// Signs out first so a failure leaves the app fully usable; cleanup after
  /// is best-effort and never blocks navigation.
  Future<void> logout() async {
    try {
      await logoutUser();
    } on AppException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    await UserSessionStorage.clear();
    HomeBinding.tearDown();
    Get.offAllNamed(AppRoutes.login);
  }
}
