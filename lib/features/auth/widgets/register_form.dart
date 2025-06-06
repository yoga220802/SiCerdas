import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/app/widgets/custom_button.dart';
import 'package:project_sicerdas/app/widgets/custom_text_field.dart';

class RegisterForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode? usernameFocusNode;
  final FocusNode? emailFocusNode;
  final FocusNode? passwordFocusNode;
  final FocusNode? confirmPasswordFocusNode;
  final VoidCallback onRegisterPressed;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.usernameFocusNode,
    this.emailFocusNode,
    this.passwordFocusNode,
    this.confirmPasswordFocusNode,
    required this.onRegisterPressed,
    this.isLoading = false,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

// Menambahkan AutomaticKeepAliveClientMixin
class _RegisterFormState extends State<RegisterForm> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  // Implementasi AutomaticKeepAliveClientMixin
  @override
  bool get wantKeepAlive => true; // Memberitahu Flutter untuk menjaga state widget ini

  @override
  Widget build(BuildContext context) {
    super.build(context); // Penting untuk memanggil super.build(context)

    return Padding(
      padding: AppSpacing.aPaddingLarge,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar Column tidak memakan space berlebih
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
              controller: widget.usernameController,
              focusNode: widget.usernameFocusNode,
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
              controller: widget.emailController,
              focusNode: widget.emailFocusNode,
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
              controller: widget.passwordController,
              focusNode: widget.passwordFocusNode,
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
              controller: widget.confirmPasswordController,
              focusNode: widget.confirmPasswordFocusNode,
              isPassword: true,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password tidak boleh kosong';
                }
                if (value != widget.passwordController.text) {
                  // Akses dari widget
                  return 'Password tidak cocok';
                }
                return null;
              },
            ),
            AppSpacing.vsLarge,
            CustomButton(
              text: 'Register',
              onPressed: () {
                // Unfocus semua field sebelum validasi dan aksi
                FocusScope.of(context).unfocus();
                if (_formKey.currentState!.validate()) {
                  widget.onRegisterPressed();
                }
              },
              isLoading: widget.isLoading,
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
