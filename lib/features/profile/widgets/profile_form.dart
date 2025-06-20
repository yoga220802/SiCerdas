import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/widgets/custom_text_field.dart';
import 'package:project_sicerdas/app/widgets/custom_button.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/features/profile/controllers/profile_controller.dart';
import 'package:provider/provider.dart';

class ProfileForm extends StatefulWidget {
  final ProfileController controller;

  const ProfileForm({super.key, required this.controller});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_showMessages);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_showMessages);
    super.dispose();
  }

  // Tampilkan pesan error atau sukses
  void _showMessages() {
    if (widget.controller.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.controller.errorMessage!), backgroundColor: AppColors.error),
      );
    } else if (widget.controller.successMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.controller.successMessage!),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.aPaddingMedium,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profil Anda', style: AppTypography.headlineSmall),
            AppSpacing.vsMedium,
            CustomTextField(
              title: 'Username',
              hintText: 'Masukkan Username',
              controller: widget.controller.usernameController,
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
              hintText: 'Masukkan Email',
              controller: widget.controller.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Masukkan email yang valid';
                }
                return null;
              },
            ),
            AppSpacing.vsMedium,
            CustomTextField(
              title: 'Password Saat Ini',
              hintText: 'Masukkan Password Saat Ini',
              controller: widget.controller.currentPasswordController,
              isPassword: true,
              obscureText: true,
            ),
            AppSpacing.vsMedium,
            CustomTextField(
              title: 'Password Baru',
              hintText: 'Kosongkan jika tidak ingin mengubah',
              controller: widget.controller.newPasswordController,
              isPassword: true,
              obscureText: true,
              validator: (value) {
                if (value != null && value.isNotEmpty && value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),
            AppSpacing.vsXLarge,
            CustomButton(
              text: 'Edit Perubahan',
              isLoading: widget.controller.isLoading,
              onPressed:
                  widget.controller.isLoading
                      ? null
                      : () {
                        if (_formKey.currentState!.validate()) {
                          widget.controller.updateProfile();
                        }
                      },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
