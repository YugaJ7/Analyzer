import 'package:analyzer/core/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validator.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/theme/app_background.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends GetView<AuthController> {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscurePassword = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        colors: [
          AppColors.background,
          AppColors.surface,
          AppColors.primary.withValues(alpha: 0.2),
        ],
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
                    AppStrings.loginTitle,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.loginSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 60),
                  CustomTextField(
                    validator: emailValidator,
                    controller: emailController,
                    label: AppStrings.email,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    focusBorderColor: AppColors.primary,
                    hint: "",
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 20),
                  Obx(
                    () => CustomTextField(
                      validator: passwordValidator,
                      controller: passwordController,
                      label: AppStrings.password,
                      icon: Icons.lock_outline,
                      obscureText: obscurePassword.value,
                      focusBorderColor: AppColors.primary,
                      hint: "",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => obscurePassword.toggle(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 32),
                  Obx(
                    () => CustomButton(
                      text: AppStrings.loginButton,
                      loading: controller.isLoading.value,
                      background: AppColors.primary,
                      onPressed: () {
                        if (_formKey.currentState!.validate()){
                          controller.login(
                            emailController.text,
                            passwordController.text,
                          );
                        }
                      },
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.noAccountPrompt,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.register),
                        child: Text(
                          AppStrings.signUpLink,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
