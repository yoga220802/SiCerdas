import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

@immutable
class NewsArticle {
  final String? id;
  final Source source;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String? content;
  final String? category;
  final bool isBookmarked;

  const NewsArticle({
    this.id,
    required this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
    this.category,
    this.isBookmarked = false,
  });

  String get uniqueId {
    return sha1.convert(utf8.encode(url)).toString();
  }

  factory NewsArticle.fromNewsApi(Map<String, dynamic> json) {
    return NewsArticle(
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      author: json['author'] as String?,
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String?,
      url: json['url'] as String? ?? '',
      urlToImage: json['urlToImage'] as String?,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ?? DateTime.now(),
      content: json['content'] as String?,
      category: json['category'] as String?,
    );
  }

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as String?,
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      author: json['author'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      url: json['url'] as String,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      content: json['content'] as String?,
      category: json['category'] as String?,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? uniqueId,
      'source': source.toJson(),
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt.toIso8601String(),
      'content': content,
      'category': category,
      'isBookmarked': isBookmarked,
    };
  }

  NewsArticle copyWith({
    String? id,
    Source? source,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    DateTime? publishedAt,
    String? content,
    String? category,
    bool? isBookmarked,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      source: source ?? this.source,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      category: category ?? this.category,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  String get formattedPublishedDate {
    return DateFormat('d MMM yyyy', 'id_ID').format(publishedAt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsArticle && runtimeType == other.runtimeType && uniqueId == other.uniqueId;

  @override
  int get hashCode => uniqueId.hashCode;
}

@immutable
class Source {
  final String? id;
  final String name;

  const Source({this.id, required this.name});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(id: json['id'] as String?, name: json['name'] as String? ?? 'Unknown Source');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class TrendingTopic {
  final String name;
  final String count;

  TrendingTopic({required this.name, required this.count});
}

class NewsSource {
  final String id;
  final String name;

  NewsSource({required this.id, required this.name});
}
