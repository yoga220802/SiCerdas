import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';

class NewsCard extends StatelessWidget {
  final NewsModel news; // Objek berita yang akan ditampilkan

  const NewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(), // Menampilkan gambar berita
          const SizedBox(width: 16),
          Expanded(child: _buildContent(context)), // Menampilkan konten berita
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image.network(
        news.featuredImageUrl ?? '', // Beri string kosong jika URL null
        fit: BoxFit.cover,
        width: 110,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 110,
            height: 120,
            color: Colors.grey.shade200,
            child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: 40),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 110,
            height: 120,
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            news.title, // Judul berita
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            news.summary, // Ringkasan berita
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textGrey),
              const SizedBox(width: 4),
              Text(
                '${news.viewCount} kali dilihat', // Jumlah tampilan berita
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const Spacer(),
              if (news.tags.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    news.tags.first, // Menampilkan tag pertama
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
