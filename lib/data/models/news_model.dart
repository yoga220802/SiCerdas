import 'package:intl/intl.dart';

class NewsModel {
  final String id;
  final String title;
  final String? slug;
  final String summary;
  final String content;
  final String? featuredImageUrl;
  final String category;
  final DateTime publishedAt;
  final List<String> tags;
  final int viewCount;
  final bool isPublished;

  NewsModel({
    required this.id,
    required this.title,
    this.slug,
    required this.summary,
    required this.content,
    this.featuredImageUrl,
    required this.category,
    required this.publishedAt,
    required this.tags,
    required this.viewCount,
    this.isPublished = true,
  });

  // Format tanggal untuk ditampilkan di UI
  String get publishedDateFormatted => DateFormat('d MMMM yyyy, HH:mm').format(publishedAt);

  // Factory constructor untuk mem-parsing JSON dari API
  factory NewsModel.fromCustomApiJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Tanpa Judul',
      slug: json['slug'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? 'Konten tidak tersedia.',
      featuredImageUrl: json['featured_image_url'],
      category: json['category'] ?? 'Umum',
      publishedAt:
          json['published_at'] != null
              ? DateTime.parse(json['published_at']).toLocal()
              : DateTime.now(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      viewCount: json['view_count'] ?? 0,
      isPublished: json['is_published'] ?? true,
    );
  }

  // Metode copyWith untuk membuat instance baru dengan perubahan
  NewsModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? summary,
    String? content,
    String? featuredImageUrl,
    String? category,
    DateTime? publishedAt,
    List<String>? tags,
    int? viewCount,
    bool? isPublished,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      featuredImageUrl: featuredImageUrl ?? this.featuredImageUrl,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
