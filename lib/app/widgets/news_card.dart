import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';

// Card besar untuk berita unggulan
class FeaturedNewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const FeaturedNewsCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias, //agar gambar tidak keluar dari border radius
        child: Stack(children: [_buildImage(), _buildGradientOverlay(), _buildContent(context)]),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.backgroundGrey,
      child:
          article.urlToImage != null && article.urlToImage!.isNotEmpty
              ? Image.network(
                article.urlToImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                },
              )
              : _buildPlaceholderImage(),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
          stops: const [0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.white,
              fontWeight: AppTypography.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.vsTiny,
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  article.source.name,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                article.formattedPublishedDate,
                style: AppTypography.caption.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return const Center(child: Icon(Icons.article_outlined, size: 48, color: AppColors.grey));
  }
}

// Card kecil untuk list berita biasa
class RegularNewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkTap;

  const RegularNewsCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    // Menggunakan InkWell untuk efek ripple saat di-tap
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: AppSpacing.aPaddingSmall,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [_buildImage(), AppSpacing.hsSmall, Expanded(child: _buildContent(context))],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 90,
        height: 90,
        color: AppColors.backgroundGrey,
        child:
            article.urlToImage != null && article.urlToImage!.isNotEmpty
                ? Image.network(
                  article.urlToImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    );
                  },
                )
                : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            article.title,
            style: AppTypography.bodyMedium.copyWith(fontWeight: AppTypography.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.category != null) ...[
                _buildTag(article.category!, AppColors.secondary),
                AppSpacing.vsSuperTiny,
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "${article.source.name} • ${article.formattedPublishedDate}",
                      style: AppTypography.caption.copyWith(color: AppColors.textGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onBookmarkTap != null)
                    InkWell(
                      onTap: onBookmarkTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          size: 20,
                          color: article.isBookmarked ? AppColors.secondary : AppColors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.overline.copyWith(color: color, fontWeight: AppTypography.bold),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return const Center(child: Icon(Icons.article_outlined, size: 24, color: AppColors.grey));
  }
}
