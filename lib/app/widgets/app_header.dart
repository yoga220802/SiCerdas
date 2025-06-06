import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/app/widgets/custom_text_field.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTap;

  const AppHeader({super.key, this.searchController, this.onSearchChanged, this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: AppSpacing.aPaddingMedium,
        color: AppColors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset('assets/images/logo.png', height: 40, width: 40),
                AppSpacing.hsSmall,
                Text(
                  'SICERDAS',
                  style: AppTypography.headlineMedium.copyWith(color: AppColors.primary),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textGrey),
                ),
              ],
            ),
            AppSpacing.vsMedium,
            CustomTextField(
              controller: searchController ?? TextEditingController(),
              onChanged: onSearchChanged,
              onTap: onSearchTap,
              hintText: 'Cari berita, topik, atau sumber...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(170.0);
}
