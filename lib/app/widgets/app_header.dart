import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/constants/app_info.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/app/widgets/custom_text_field.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTop;

  const AppHeader({super.key, this.searchController, this.onSearchChanged, this.onSearchTop});

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
                Image.asset('assets/images/logo.png', width: 40, height: 40),
                AppSpacing.hsSmall,
                Text(
                  AppInfo.appName,
                  style: AppTypography.headlineMedium.copyWith(color: AppColors.primary),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_outlined, color: AppColors.grey),
                ),
              ],
            ),
            AppSpacing.vsMedium,
            CustomTextField(
              hintText: "Cari Berita...",
              controller: searchController ?? TextEditingController(),
              onChanged: onSearchChanged,
              onTap: onSearchTop,
              prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
}
