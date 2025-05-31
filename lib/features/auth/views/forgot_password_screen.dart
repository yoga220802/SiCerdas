import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/app/widgets/custom_button.dart';
import 'package:project_sicerdas/app/widgets/custom_text_field.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isDialogVisible = false;

  void _showResetConfirmationDialog() {
    if (mounted) {
      // Pastikan widget masih ada di tree
      setState(() => _isDialogVisible = true);
    }
  }

  void _hideResetConfirmationDialogAndGoBack() {
    if (mounted) {
      setState(() => _isDialogVisible = false);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  Future<void> _handleResetPassword(AuthController authController) async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      bool success = await authController.forgotPassword(email: _emailController.text);

      if (mounted) {
        // Selalu cek mounted setelah async call
        if (success) {
          _showResetConfirmationDialog();
        } else if (authController.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authController.errorMessage!), backgroundColor: AppColors.error),
          );
        } else {
          // Kasus lain jika tidak sukses tapi tidak ada error message spesifik
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gagal mengirim email reset. Coba lagi."),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(), // Buat instance baru
      child: Consumer<AuthController>(
        // Gunakan Consumer untuk mendapatkan instance AuthController
        builder: (context, authController, child) {
          // authController adalah instance dari Provider
          return Scaffold(
            backgroundColor: AppColors.secondary,
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: AppSpacing.hPaddingLarge,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                        const Icon(Icons.lock_outline, size: 60, color: AppColors.textBlack),
                        AppSpacing.vsMedium,
                        Text(
                          'Lupa Kata Sandi?',
                          style: AppTypography.displaySmall.copyWith(color: AppColors.textBlack),
                        ),
                        AppSpacing.vsMedium,
                        Text(
                          'Jangan khawatir, kami akan membantu Anda mengatur ulang dengan mudah dan cepat.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textGrey),
                        ),
                        AppSpacing.vsXLarge,
                        Container(
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
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 50,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported, size: 50),
                              ),
                              AppSpacing.vsLarge,
                              CustomTextField(
                                title: 'Email',
                                hintText: 'Masukan email terdaftar',
                                controller: _emailController,
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
                            ],
                          ),
                        ),
                        AppSpacing.vsXLarge,
                        CustomButton(
                          text: 'Reset Password',
                          onPressed:
                              authController.isLoading
                                  ? null
                                  : () =>
                                      _handleResetPassword(authController), // Kirim authController
                          isLoading: authController.isLoading,
                          width: double.infinity,
                          type: ButtonType.outline,
                          customOutlineColor: AppColors.white,
                        ),
                        AppSpacing.vsMedium,
                        CustomButton(
                          text: 'Kembali',
                          onPressed: authController.isLoading ? null : () => Navigator.pop(context),
                          width: double.infinity,
                          type: ButtonType.text,
                          customOutlineColor: AppColors.white,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                      ],
                    ),
                  ),
                ),
                if (_isDialogVisible) _buildConfirmationDialog(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfirmationDialog(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        color: AppColors.black.withValues(alpha: 0.3),
        child: Center(
          child: Container(
            margin: AppSpacing.hPaddingLarge.copyWith(left: 40, right: 40),
            padding: AppSpacing.hPaddingLarge,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: _hideResetConfirmationDialogAndGoBack,
                    icon: const Icon(Icons.close, color: AppColors.textGrey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 30, color: AppColors.secondary),
                ),
                AppSpacing.vsMedium,
                Text(
                  'Kami telah mengirimkan email untuk reset kata sandi. Silakan cek dan konfirmasi jika itu Anda.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textBlack),
                ),
                AppSpacing.vsSmall,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
