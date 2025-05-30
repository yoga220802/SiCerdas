import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/app/widgets/custom_button.dart';
import 'package:project_sicerdas/app/widgets/custom_text_field.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode? usernameFocusNode; // Tambahkan FocusNode
  final FocusNode? emailFocusNode; // Tambahkan FocusNode
  final FocusNode? passwordFocusNode; // Tambahkan FocusNode
  final FocusNode? confirmPasswordFocusNode; // Tambahkan FocusNode
  final VoidCallback onRegisterPressed;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.usernameFocusNode, // Jadikan opsional
    this.emailFocusNode, // Jadikan opsional
    this.passwordFocusNode, // Jadikan opsional
    this.confirmPasswordFocusNode, // Jadikan opsional
    required this.onRegisterPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Padding(
      padding: AppSpacing.aPaddingLarge,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const Icon(Icons.person_add_outlined, size: 50, color: AppColors.textBlack),
            AppSpacing.vsMedium,
            Text(
              'Buat Akun',
              style: AppTypography.headlineSmall.copyWith(color: AppColors.textBlack),
            ),
            AppSpacing.vsSmall,
            Text(
              'Buat akun sehingga Anda dapat menjelajahi semua berita yang tersedia.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textGrey),
            ),
            AppSpacing.vsLarge,
            Image.asset(
              'assets/images/logo.png',
              height: 50,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50),
            ),
            AppSpacing.vsLarge,
            CustomTextField(
              title: 'Username',
              hintText: 'Masukkan username',
              controller: usernameController,
              focusNode: usernameFocusNode, // Gunakan FocusNode
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username tidak boleh kosong';
                }
                return null;
              },
            ),
            AppSpacing.vsMedium,
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
                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),
            AppSpacing.vsMedium,
            CustomTextField(
              title: 'Konfirmasi Password',
              hintText: '••••••••••',
              controller: confirmPasswordController,
              focusNode: confirmPasswordFocusNode, // Gunakan FocusNode
              isPassword: true,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password tidak boleh kosong';
                }
                if (value != passwordController.text) {
                  return 'Password tidak cocok';
                }
                return null;
              },
            ),
            AppSpacing.vsLarge,
            CustomButton(
              text: 'Register',
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  onRegisterPressed();
                }
              },
              isLoading: isLoading,
              width: double.infinity,
              customBackgroundColor: AppColors.secondary,
              customTextColor: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}
