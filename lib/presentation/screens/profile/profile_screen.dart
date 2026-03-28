import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';
import '../../../core/routes/app_routes.dart';

import 'widgets/avatar_picker_sheet.dart';
import 'widgets/profile_edit_dialog.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_logout_button.dart';
import 'widgets/profile_section_card.dart';
import 'widgets/profile_setting_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return SafeArea(
      child: Obx(() {
        final user = controller.user;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
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

                  // AVATAR
                  ProfileHeader(
                    selectedAvatar: controller.selectedAvatar.value,
                    displayName: controller.displayName.value,
                    email: user?.email ?? '',
                    onAvatarTap: () =>
                        _showAvatarPicker(context, controller),
                  ),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        /// HABITS
                        ProfileSectionCard(
                          title: 'Habits',
                          children: [
                            ProfileSettingRow(
                              icon: Icons.list_rounded,
                              iconColor: const Color(0xFF6C63FF),
                              label: 'Manage Habits',
                              subtitle: 'Add, delete, enable/disable',
                              onTap: () =>
                                  Get.toNamed(AppRoutes.manageHabits),
                            ),
                          ],
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 14),

                        /// DATA
                        ProfileSectionCard(
                          title: 'Data',
                          children: [
                            ProfileSettingRow(
                              icon: Icons.upload_file_rounded,
                              iconColor: const Color(0xFF4ECDC4),
                              label: 'Export as CSV',
                              subtitle:
                                  'Share habit history spreadsheet',
                              trailing: controller.isExporting.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : null,
                              onTap: controller.isExporting.value
                                  ? null
                                  : controller.exportCsv,
                            ),
                            _divider(),
                            ProfileSettingRow(
                              icon: Icons.picture_as_pdf_rounded,
                              iconColor: const Color(0xFFFF6B6B),
                              label: 'Share Full Report',
                              subtitle:
                                  'PDF with all data, habits & graphs',
                              trailing: controller.isExporting.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : null,
                              onTap: controller.isExporting.value
                                  ? null
                                  : controller.exportPdf,
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        /// ACCOUNT
                        ProfileSectionCard(
                          title: 'Account',
                          children: [
                            ProfileSettingRow(
                              icon: Icons.person_outline_rounded,
                              iconColor: const Color(0xFF6C63FF),
                              label: 'Change Name',
                              subtitle:
                                  controller.displayName.value,
                              onTap: () =>
                                  _showChangeNameDialog(
                                      context, controller),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        /// SECURITY
                        ProfileSectionCard(
                          title: 'Security',
                          children: [
                            ProfileSettingRow(
                              icon: Icons.fingerprint_rounded,
                              iconColor: const Color(0xFF4ECDC4),
                              label: 'Biometric Lock',
                              subtitle:
                                  'Require fingerprint/face on open',
                              trailing: Switch(
                                value:
                                    controller.biometricEnabled.value,
                                onChanged:
                                    controller.toggleBiometric,
                              ),
                              onTap: null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        const ProfileLogoutButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        color: Colors.white.withValues(alpha: 0.06),
        indent: 56,
      );

  void _showAvatarPicker(
      BuildContext context,
      ProfileController controller) {
    showModalBottomSheet(
      context: context,
      builder: (_) => AvatarPickerSheet(
        avatarEmojis: ProfileController.avatarEmojis,
        selectedAvatar: controller.selectedAvatar.value,
        onSelect: controller.saveAvatar,
      ),
    );
  }

  void _showChangeNameDialog(
      BuildContext context,
      ProfileController controller) {
    final ctrl = TextEditingController(
      text: controller.displayName.value,
    );

    showDialog(
      context: context,
      builder: (_) => ProfileEditDialog(
        title: 'Change Name',
        controller: ctrl,
        hint: 'Enter your name', // ✅ kept
        onSave: () {
          controller.updateName(ctrl.text.trim());
        },
      ),
    );
  }
}