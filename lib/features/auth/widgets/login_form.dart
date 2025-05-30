import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/app/widgets/custom_button.dart';
import 'package:project_sicerdas/app/widgets/custom_text_field.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode? emailFocusNode;
  final FocusNode? passwordFocusNode;
  final VoidCallback onLoginPressed;
  final VoidCallback onForgotPasswordPressed;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.emailFocusNode,
    this.passwordFocusNode,
    required this.onLoginPressed,
    required this.onForgotPasswordPressed,
    this.isLoading = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

// Menambahkan AutomaticKeepAliveClientMixin
class _LoginFormState extends State<LoginForm> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar Column tidak memakan space berlebih
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
              controller: widget.emailController, // Mengakses controller dari widget
              focusNode: widget.emailFocusNode, // Mengakses focus node dari widget
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
              controller: widget.passwordController, // Mengakses controller dari widget
              focusNode: widget.passwordFocusNode, // Mengakses focus node dari widget
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
                onPressed: widget.isLoading ? null : widget.onForgotPasswordPressed,
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
                // Unfocus semua field sebelum validasi dan aksi
                FocusScope.of(context).unfocus();
                if (_formKey.currentState!.validate()) {
                  widget.onLoginPressed();
                }
              },
              isLoading: widget.isLoading,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
