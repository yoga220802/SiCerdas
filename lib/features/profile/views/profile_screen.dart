import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart';
import 'package:project_sicerdas/features/auth/views/auth_screen.dart';
import 'package:project_sicerdas/features/profile/controllers/profile_controller.dart';
import 'package:project_sicerdas/features/profile/widgets/profile_form.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => ProfileController(
            authController: Provider.of<AuthController>(context, listen: false),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Profil Pengguna',
            style: AppTypography.headlineSmall.copyWith(color: AppColors.textBlack),
          ),
          centerTitle: true,
          backgroundColor: AppColors.white,
          elevation: 1,
        ),
        body: Consumer<ProfileController>(
          builder: (context, controller, child) {
            // Tampilkan loading indicator jika data masih dimuat
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Tampilkan pesan error jika ada
            if (controller.errorMessage != null) {
              return Center(child: Text('Error: ${controller.errorMessage}'));
            }

            // Tampilkan UI profil setelah data dimuat
            return SingleChildScrollView(
              padding: AppSpacing.aPaddingLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileHeader(context, controller),
                  AppSpacing.vsXLarge,
                  ProfileForm(controller: controller),
                  AppSpacing.vsXLarge,
                  _buildLogoutButton(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Header profil (avatar dan nama)
  Widget _buildProfileHeader(BuildContext context, ProfileController controller) {
    final userModel = controller.authController.userModel;
    final displayName = userModel?.displayName ?? 'SICERDAS';
    final email = userModel?.email ?? 'sicerdas@gmail.com';
    final photoUrl = userModel?.photoUrl;

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
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage:
                    (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                child:
                    (photoUrl == null || photoUrl.isEmpty)
                        ? Icon(Icons.person, size: 60, color: AppColors.primary)
                        : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    await controller.uploadProfilePicture();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child:
                        controller.isUploadingPhoto
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            )
                            : Icon(Icons.edit, color: AppColors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vsMedium,
          Text(
            displayName,
            style: AppTypography.headlineMedium.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vsTiny,
          Text(
            email,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Tombol logout
  Widget _buildLogoutButton(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);

    return OutlinedButton.icon(
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
      icon: Icon(Icons.logout, color: AppColors.error),
      label: Text('Keluar', style: AppTypography.titleMedium.copyWith(color: AppColors.error)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.error, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: AppSpacing.aPaddingMedium,
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }
}
