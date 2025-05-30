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
  late AuthController _authController; // Instance AuthController

  @override
  void initState() {
    super.initState();
    // Inisialisasi AuthController. Idealnya di-provide dari atas jika sudah pakai Provider secara global
    _authController = AuthController();
  }

  void _showResetConfirmationDialog() {
    setState(() => _isDialogVisible = true);
  }

  void _hideResetConfirmationDialogAndGoBack() {
    setState(() => _isDialogVisible = false);
    // Tunggu dialog hilang sebelum pop, atau pop langsung jika tidak ada animasi keluar
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Tutup keyboard

      await _authController.forgotPassword(email: _emailController.text);

      if (mounted && _authController.errorMessage == null && !_authController.isLoading) {
        _showResetConfirmationDialog();
      } else if (mounted && _authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authController.errorMessage!), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authController.dispose(); // Jangan lupa dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Dengarkan perubahan pada AuthController
    return ChangeNotifierProvider.value(
      value: _authController,
      child: Consumer<AuthController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: AppColors.secondary, // Background biru muda
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: AppSpacing.hPaddingLarge,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Spasi atas
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
                                  if (value == null || value.isEmpty)
                                    return 'Email tidak boleh kosong';
                                  if (!value.contains('@') || !value.contains('.'))
                                    return 'Format email tidak valid';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.vsXLarge,
                        CustomButton(
                          text: 'Reset Password',
                          onPressed: _handleResetPassword,
                          isLoading: controller.isLoading, // Ambil status loading dari controller
                          width: double.infinity,
                          type: ButtonType.outline, // Tombol outline
                          customOutlineColor: AppColors.white, // Border dan teks putih
                          customTextColor: AppColors.textWhite, // Teks putih
                        ),
                        AppSpacing.vsMedium,
                        CustomButton(
                          text: 'Kembali',
                          onPressed: () => Navigator.pop(context),
                          width: double.infinity,
                          type: ButtonType.text, // Tombol teks
                          customTextColor: AppColors.textWhite, // Teks putih
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Spasi bawah
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
            margin: AppSpacing.hPaddingLarge.copyWith(left: 40, right: 40), // Margin lebih besar
            padding: AppSpacing.aPaddingLarge,
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
                  padding: const EdgeInsets.all(12), // Padding untuk ikon check
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2), // Warna background ikon
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 30,
                    color: AppColors.secondary,
                  ), // Ukuran ikon disesuaikan
                ),
                AppSpacing.vsMedium,
                Text(
                  'Kami telah mengirimkan email untuk reset kata sandi. Silakan cek dan konfirmasi jika itu Anda.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textBlack),
                ),
                AppSpacing.vsSmall, // Spasi sebelum tombol OK
              ],
            ),
          ),
        ),
      ),
    );
  }
}
