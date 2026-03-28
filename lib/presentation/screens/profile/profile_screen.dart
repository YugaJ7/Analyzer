import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/analytics_controller.dart';
import '../../controllers/parameter_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../data/services/export_service.dart';
import 'widgets/avatar_picker_sheet.dart';
import 'widgets/profile_edit_dialog.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_logout_button.dart';
import 'widgets/profile_section_card.dart';
import 'widgets/profile_setting_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricEnabled = false;
  String _selectedAvatar = '🧠';
  bool _isExporting = false;
  String _displayName = 'User';

  late final ExportService _exportService;
  final _userRepo = UserRepositoryImpl();

  // Avatar options
  static const _avatarEmojis = [
    '🧠',
    '🚀',
    '🌟',
    '💪',
    '🎯',
    '🦁',
    '🔥',
    '⚡',
    '🌿',
    '🏆',
    '🎭',
    '🌈',
    '💎',
    '🦅',
    '🐉',
    '🌙',
  ];

  @override
  void initState() {
    super.initState();
    final analytics = Get.find<AnalyticsController>();
    final params = Get.find<ParameterController>();
    _exportService = ExportService(analytics: analytics, parameters: params);
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _biometricEnabled = prefs.getBool('biometric_lock') ?? false;
      _selectedAvatar = prefs.getString('avatar_emoji') ?? '🧠';
    });
    if (user != null) {
      try {
        final userEntity = await _userRepo.getUser(user.uid);
        final name = userEntity?.name;
        if (mounted) {
          setState(() {
            _displayName = (name != null && name.isNotEmpty)
                ? name
                : (user.displayName?.isNotEmpty == true
                      ? user.displayName!
                      : user.email?.split('@').first ?? 'User');
          });
        }
      } catch (e) {
        log('Failed to load user name: $e');
        if (mounted) {
          setState(() {
            _displayName =
                user.displayName ?? user.email?.split('@').first ?? 'User';
          });
        }
      }
    }
  }

  Future<void> _saveBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_lock', value);
    setState(() => _biometricEnabled = value);
  }

  Future<void> _saveAvatar(String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_emoji', emoji);
    setState(() => _selectedAvatar = emoji);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = _displayName;
    final email = user?.email ?? '';

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn().slideX(begin: -0.1),
                ),

                const SizedBox(height: 24),

                // ── Avatar Area ──────────────────────────────────
                ProfileHeader(
                  selectedAvatar: _selectedAvatar,
                  displayName: displayName,
                  email: email,
                  onAvatarTap: () => _showAvatarPicker(context),
                ),
                const SizedBox(height: 32),

                // ── Body Sections ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Habits
                      ProfileSectionCard(
                        title: 'Habits',
                        children: [
                          ProfileSettingRow(
                            icon: Icons.list_rounded,
                            iconColor: const Color(0xFF6C63FF),
                            label: 'Manage Habits',
                            subtitle: 'Add, delete, enable/disable',
                            onTap: () => Get.toNamed(AppRoutes.manageHabits),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
                      const SizedBox(height: 14),

                      // Data Export
                      ProfileSectionCard(
                        title: 'Data',
                        children: [
                          ProfileSettingRow(
                            icon: Icons.upload_file_rounded,
                            iconColor: const Color(0xFF4ECDC4),
                            label: 'Export as CSV',
                            subtitle: 'Share habit history spreadsheet',
                            trailing: _isExporting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF4ECDC4),
                                    ),
                                  )
                                : null,
                            onTap: _isExporting
                                ? null
                                : () async {
                                    setState(() => _isExporting = true);
                                    try {
                                      await _exportService.exportCsv();
                                    } catch (e) {
                                      Get.snackbar(
                                        'Export Failed',
                                        e.toString(),
                                        backgroundColor: const Color(
                                          0xFFFF6B6B,
                                        ),
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    } finally {
                                      setState(() => _isExporting = false);
                                    }
                                  },
                          ),
                          _divider(),
                          ProfileSettingRow(
                            icon: Icons.picture_as_pdf_rounded,
                            iconColor: const Color(0xFFFF6B6B),
                            label: 'Share Full Report',
                            subtitle: 'PDF with all data, habits & graphs',
                            trailing: _isExporting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFFF6B6B),
                                    ),
                                  )
                                : null,
                            onTap: _isExporting
                                ? null
                                : () async {
                                    setState(() => _isExporting = true);
                                    try {
                                      await _exportService.exportPdf();
                                    } catch (e) {
                                      Get.snackbar(
                                        'Export Failed',
                                        e.toString(),
                                        backgroundColor: const Color(
                                          0xFFFF6B6B,
                                        ),
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    } finally {
                                      setState(() => _isExporting = false);
                                    }
                                  },
                          ),
                        ],
                      ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05),
                      const SizedBox(height: 14),

                      // Account
                      ProfileSectionCard(
                        title: 'Account',
                        children: [
                          ProfileSettingRow(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFF6C63FF),
                            label: 'Change Name',
                            subtitle: displayName,
                            onTap: () => _showChangeNameDialog(context, user),
                          ),
                          _divider(),
                          ProfileSettingRow(
                            icon: Icons.email_outlined,
                            iconColor: const Color(0xFF4ECDC4),
                            label: 'Change Email',
                            subtitle: email,
                            onTap: () => _showChangeEmailDialog(context, user),
                          ),
                          _divider(),
                          ProfileSettingRow(
                            icon: Icons.lock_outline_rounded,
                            iconColor: const Color(0xFFFFD700),
                            label: 'Change Password',
                            subtitle: '••••••••',
                            onTap: () =>
                                _showChangePasswordDialog(context, user),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
                      const SizedBox(height: 14),

                      // Security
                      ProfileSectionCard(
                        title: 'Security',
                        children: [
                          ProfileSettingRow(
                            icon: Icons.fingerprint_rounded,
                            iconColor: const Color(0xFF4ECDC4),
                            label: 'Biometric Lock',
                            subtitle: 'Require fingerprint/face on open',
                            trailing: Switch(
                              value: _biometricEnabled,
                              onChanged: (val) =>
                                  _toggleBiometric(context, val),
                              activeThumbColor: const Color(0xFF4ECDC4),
                              inactiveTrackColor: Colors.white.withValues(
                                alpha: 0.1,
                              ),
                              inactiveThumbColor: Colors.white.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            onTap: null,
                          ),
                        ],
                      ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05),
                      const SizedBox(height: 24),

                      // Sign Out
                      const ProfileLogoutButton()
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: 0.05),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    color: Colors.white.withValues(alpha: 0.06),
    indent: 56,
  );

  // ── Avatar Picker ───────────────────────────
  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2749),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AvatarPickerSheet(
        avatarEmojis: _avatarEmojis,
        selectedAvatar: _selectedAvatar,
        onSelect: _saveAvatar,
      ),
    );
  }

  // ── Biometric ───────────────────────────────
  Future<void> _toggleBiometric(BuildContext context, bool value) async {
    if (value) {
      try {
        final auth = LocalAuthentication();
        final canCheck = await auth.canCheckBiometrics;
        if (!canCheck) {
          Get.snackbar(
            'Not Available',
            'No biometrics enrolled on this device',
            backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        final authenticated = await auth.authenticate(
          localizedReason: 'Authenticate to enable biometric lock',
        );
        if (!authenticated) return;
      } on PlatformException {
        // Biometrics not available on this device/emulator
        Get.snackbar(
          'Not Available',
          'Biometric authentication is not supported on this device',
          backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      } catch (_) {
        Get.snackbar(
          'Error',
          'Could not enable biometric lock. Try again.',
          backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }
    await _saveBiometric(value);
  }

  // ── Account Edit Dialogs ─────────────────────
  void _showChangeNameDialog(BuildContext context, User? user) {
    final ctrl = TextEditingController(text: _displayName);
    showDialog(
      context: context,
      builder: (_) => ProfileEditDialog(
        title: 'Change Name',
        controller: ctrl,
        hint: 'Enter your name',
        onSave: () async {
          final newName = ctrl.text.trim();
          if (newName.isEmpty) return;
          await user?.updateDisplayName(newName);
          if (mounted) setState(() => _displayName = newName);
          Get.snackbar(
            'Updated',
            'Name updated successfully',
            backgroundColor: const Color(0xFF4ECDC4).withValues(alpha: 0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          if (user != null) {
            await _userRepo.updateUser(user.uid, {'name': newName});
          }
        },
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context, User? user) {
    final ctrl = TextEditingController(text: user?.email ?? '');
    showDialog(
      context: context,
      builder: (_) => ProfileEditDialog(
        title: 'Change Email',
        controller: ctrl,
        hint: 'Enter new email',
        keyboardType: TextInputType.emailAddress,
        onSave: () async {
          await user?.verifyBeforeUpdateEmail(ctrl.text.trim());
          Get.snackbar(
            'Verification Sent',
            'Check your new email for a verification link',
            backgroundColor: const Color(0xFF4ECDC4).withValues(alpha: 0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, User? user) {
    final newPassCtrl = TextEditingController();
    final currentPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Current Password"),
            ),
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final email = user?.email;

                if (email == null) return;

                // 🔐 Re-authenticate
                final cred = EmailAuthProvider.credential(
                  email: email,
                  password: currentPassCtrl.text.trim(),
                );

                await user!.reauthenticateWithCredential(cred);

                // ✅ Now update password
                await user.updatePassword(newPassCtrl.text.trim());

                Navigator.pop(context);

                Get.snackbar(
                  'Success',
                  'Password updated successfully',
                  backgroundColor: const Color(0xFF4ECDC4),
                  colorText: Colors.white,
                );
              } on FirebaseAuthException catch (e) {
                Get.snackbar(
                  'Error',
                  e.message ?? 'Something went wrong',
                  backgroundColor: const Color(0xFFFF6B6B),
                  colorText: Colors.white,
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
