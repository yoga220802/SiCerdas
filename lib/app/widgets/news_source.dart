import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';

class NewsSourcesWidget extends StatelessWidget {
  final List<ApiSource> sources;
  final Function(String) onSourceTap;

  const NewsSourcesWidget({super.key, required this.sources, required this.onSourceTap});

  // Fungsi untuk mendapatkan URL logo dari Clearbit berdasarkan URL sumber berita
  String _getLogoUrl(String? sourceUrl) {
    if (sourceUrl == null || sourceUrl.isEmpty) {
      return ''; // Kembalikan string kosong jika URL tidak ada
    }
    try {
      final domain = Uri.parse(sourceUrl).host;
      // Bersihkan 'www.' jika ada untuk hasil yang lebih baik
      final cleanDomain = domain.startsWith('www.') ? domain.substring(4) : domain;
      return 'https://logo.clearbit.com/$cleanDomain';
    } catch (e) {
      print('Error parsing URL for logo: $sourceUrl');
      return ''; // Kembalikan string kosong jika terjadi error
    }
  }

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
          final logoUrl = _getLogoUrl(source.url);

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
                child: ClipOval(
                  child: Image.network(
                    logoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Placeholder jika logo gagal dimuat atau URL kosong
                      return Container(
                        color: AppColors.lightGrey,
                        child: Center(
                          child: Text(
                            source.name.substring(0, 1).toUpperCase(),
                            style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
