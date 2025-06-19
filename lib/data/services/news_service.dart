import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_sicerdas/data/models/news_model.dart';

class NewsService {
  final String _baseUrl = "https://newsapi.org/v2";
  // Ambil API Key dari environment variables
  final String? _apiKey = dotenv.env['NEWS_API_KEY'];

  // Fungsi internal untuk melakukan fetch dan parse data
  Future<List<NewsArticle>> _fetchNewsData(String url) async {
    if (_apiKey == null) {
      throw Exception('NEWS_API_KEY tidak ditemukan di file .env');
    }
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'ok') {
          final List articles = jsonResponse['articles'];
          return articles
              .where((article) => article['title'] != null && article['url'] != null)
              .map((article) => NewsArticle.fromNewsApi(article))
              .toList();
        } else {
          throw Exception('Gagal mendapatkan berita: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Gagal terhubung ke server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error di NewsService: $e');
      throw Exception('Terjadi kesalahan saat mengambil data berita.');
    }
  }

  // Fungsi untuk mendapatkan berita utama (top headlines)
  Future<List<NewsArticle>> getTopHeadlines({String country = 'us'}) async {
    final url = '$_baseUrl/top-headlines?country=$country&apiKey=$_apiKey';
    return _fetchNewsData(url);
  }

  // Fungsi untuk mendapatkan berita berdasarkan kategori
  Future<List<NewsArticle>> getNewsByCategory({
    required String category,
    String country = 'us',
  }) async {
    final url =
        '$_baseUrl/top-headlines?country=$country&category=${category.toLowerCase()}&apiKey=$_apiKey';
    return _fetchNewsData(url);
  }

  Future<List<ApiSource>> getSources({
    String language = 'en',
    String? category, // <-- TAMBAHKAN PARAMETER KATEGORI (nullable)
  }) async {
    if (_apiKey == null) throw Exception('NEWS_API_KEY tidak ditemukan di file .env');

    var url = '$_baseUrl/top-headlines/sources?language=$language&apiKey=$_apiKey';
    // Jika ada kategori, tambahkan ke URL
    if (category != null && category.isNotEmpty && category != 'semua') {
      url += '&category=${category.toLowerCase()}';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'ok') {
          final List sources = jsonResponse['sources'];
          return sources.map((source) => ApiSource.fromSourceApi(source)).toList();
        } else {
          throw Exception('Gagal mendapatkan sumber berita: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Gagal terhubung ke server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error di NewsService (getSources): $e');
      throw Exception('Terjadi kesalahan saat mengambil data sumber berita.');
    }
  }
}
