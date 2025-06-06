import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';

class CategoryTabs extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final List<String> categories;

  const CategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.hPaddingMedium,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => onCategoryChanged(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  category,
                  style: (isSelected
                          ? AppTypography.labelMedium.copyWith(color: AppColors.textWhite)
                          : AppTypography.labelLarge.copyWith(color: AppColors.textGrey))
                      .copyWith(fontWeight: AppTypography.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
