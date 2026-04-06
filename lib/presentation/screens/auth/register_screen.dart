import 'package:analyzer/core/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validator.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/theme/app_background.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends GetView<AuthController> {
  RegisterScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        colors: [AppColors.background, AppColors.surface, AppColors.secondary.withValues(alpha: 0.2)],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(   
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    AppStrings.registerTitle,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.registerSubtitle,
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 40),

                  CustomTextField(
                    validator: nameValidator,
                    controller: nameController,
                    label: AppStrings.fullName,
                    hint: "",
                    icon: Icons.person_outline,
                    focusBorderColor: AppColors.secondary,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),
                  CustomTextField(
                    validator: emailValidator,
                    controller: emailController,
                    label: AppStrings.email,
                    hint: "",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    focusBorderColor: AppColors.secondary,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),
                  Obx(() => CustomTextField(
                        validator: passwordValidator,
                        controller: passwordController,
                        label: AppStrings.password,
                        hint: "",
                        icon: Icons.lock_outline,
                        obscureText: obscurePassword.value,
                        focusBorderColor: AppColors.secondary,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => obscurePassword.toggle(),
                        ),
                      )).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),
                  Obx(() => CustomTextField(
                        validator: passwordValidator,
                        controller: confirmPasswordController,
                        label: AppStrings.confirmPassword,
                        hint: "",
                        icon: Icons.lock_outline,
                        obscureText: obscureConfirmPassword.value,
                        focusBorderColor: AppColors.secondary,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => obscureConfirmPassword.toggle(),
                        ),
                      )).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 32),
                  Obx(() => CustomButton(
                        text: AppStrings.registerButton,
                        loading: controller.isLoading.value,
                        background: AppColors.secondary,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            controller.register(
                              emailController.text,
                              passwordController.text,
                              nameController.text,
                            );
                          }
                        },
                      )).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.noAccountPrompt, style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text(AppStrings.signInLink, style: TextStyle(color: AppColors.secondary, fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
