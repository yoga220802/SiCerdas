import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';

class NewsSourcesWidget extends StatelessWidget {
  final List<NewsSource> sources;
  final Function(String) onSourceTap;

  const NewsSourcesWidget({super.key, required this.sources, required this.onSourceTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.hPaddingMedium,
        itemCount: sources.length,
        itemBuilder: (context, index) {
          final source = sources[index];

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => onSourceTap(source.id),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.lightGrey, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(child: _buildSourceLogo(source)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSourceLogo(NewsSource source) {
    // TODO: Ganti dengan logo asli dari API atau asset lokal
    // Contoh pemetaan sederhana untuk logo lokal:
    final logoMap = {
      // 'cnn': 'assets/logos/cnn_logo.png',
      // 'inews': 'assets/logos/inews_logo.png',
      // 'bbc-news': 'assets/logos/bbc_logo.png',
    };

    if (logoMap.containsKey(source.id)) {
      return Image.asset(logoMap[source.id]!, fit: BoxFit.contain);
    }

    return Container(
      color: AppColors.lightGrey,
      child: Center(
        child: Text(
          source.name.substring(0, 1).toUpperCase(),
          style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
