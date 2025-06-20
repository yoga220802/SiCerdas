/// file: lib/data/models/news_model.dart

import 'package:intl/intl.dart';

class NewsModel {
  final String id;
  final String title;
  final String slug;
  final String summary;
  final String content;
  final String? featuredImageUrl; // Nullable karena tidak selalu ada
  final String category;
  final DateTime publishedAt;

  final List<String> tags; // Daftar tag berita
  final int viewCount; // Jumlah tampilan berita

  NewsModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    required this.content,
    this.featuredImageUrl,
    required this.category,
    required this.publishedAt,
    required this.tags,
    required this.viewCount,
  });

  // Format tanggal untuk ditampilkan di UI
  String get publishedDateFormatted => DateFormat('d MMMM yyyy, HH:mm').format(publishedAt);

  // Factory constructor untuk mem-parsing JSON dari API kustom
  factory NewsModel.fromCustomApiJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Tanpa Judul',
      slug: json['slug'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? 'Konten tidak tersedia.',
      featuredImageUrl: json['featured_image_url'], // Bisa null
      category: json['category'] ?? 'Umum',
      publishedAt:
          json['published_at'] != null
              ? DateTime.parse(json['published_at']).toLocal()
              : DateTime.now(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      viewCount: json['view_count'] ?? 0,
    );
  }
}
