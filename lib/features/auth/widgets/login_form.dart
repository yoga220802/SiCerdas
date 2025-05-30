import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/app/widgets/custom_button.dart';
import 'package:project_sicerdas/app/widgets/custom_text_field.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode? emailFocusNode; // Tambahkan FocusNode
  final FocusNode? passwordFocusNode; // Tambahkan FocusNode
  final VoidCallback onLoginPressed;
  final VoidCallback onForgotPasswordPressed;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.emailFocusNode, // Jadikan opsional
    this.passwordFocusNode, // Jadikan opsional
    required this.onLoginPressed,
    required this.onForgotPasswordPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Container(
      padding: AppSpacing.aPaddingLarge,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 60,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 60),
            ),
            AppSpacing.vsLarge,
            CustomTextField(
              title: 'Email',
              hintText: 'sicerdas@example.com',
              controller: emailController,
              focusNode: emailFocusNode, // Gunakan FocusNode
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            AppSpacing.vsMedium,
            CustomTextField(
              title: 'Password',
              hintText: '••••••••••',
              controller: passwordController,
              focusNode: passwordFocusNode, // Gunakan FocusNode
              isPassword: true,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLoading ? null : onForgotPasswordPressed,
                child: Text(
                  'Lupa password?',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textGrey),
                ),
              ),
            ),
            AppSpacing.vsLarge,
            CustomButton(
              text: 'Login',
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  onLoginPressed();
                }
              },
              isLoading: isLoading,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
