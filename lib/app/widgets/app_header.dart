import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart';
import 'package:project_sicerdas/features/auth/views/auth_screen.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);

    return SafeArea(
      child: Container(
        height: 20,
        padding: AppSpacing.hPaddingMedium,
        color: AppColors.white,
        child: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 40, width: 40),
            AppSpacing.hsSmall,
            Text(
              'SICERDAS',
              style: AppTypography.headlineMedium.copyWith(color: AppColors.primary),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout_outlined, color: AppColors.primary),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Konfirmasi Logout'),
                      content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Batal'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Logout', style: TextStyle(color: AppColors.error)),
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            await authController.logoutUser();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const AuthScreen()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}
