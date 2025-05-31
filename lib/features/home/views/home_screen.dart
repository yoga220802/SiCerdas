import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/widgets/custom_button.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart';
import 'package:project_sicerdas/features/auth/views/auth_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _handleLogout() async {
    final authController = Provider.of<AuthController>(context, listen: false);

    await authController.logoutUser();

    if (mounted) {
      // Selalu cek mounted setelah async call
      // Navigasi ke AuthScreen dan hapus semua route sebelumnya
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (Route<dynamic> route) => false, // Hapus semua route sebelumnya dari stack
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Beranda Sicerdas',
          style: AppTypography.headlineMedium,
          selectionColor: AppColors.black,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.black),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.aPaddingLarge,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work_outlined, size: 80, color: theme.colorScheme.primary),
              AppSpacing.vsMedium,
              Text(
                'Selamat Datang di Beranda!',
                // 'Selamat Datang, ${authController.currentUser?.displayName ?? 'Pengguna'}!',
                style: AppTypography.headlineSmall.copyWith(color: theme.colorScheme.primary),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vsSmall,
              Text(
                'Ini adalah halaman utama aplikasi Sicerdas setelah Anda berhasil login. Konten berita akan ditampilkan di sini.',
                style: AppTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              // TODO: Tambahkan UI untuk menampilkan daftar berita
              AppSpacing.vsLarge,
              // Tombol logout alternatif di body jika diperlukan
              CustomButton(
                text: "Logout dari Sini",
                onPressed: _handleLogout,
                type: ButtonType.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
