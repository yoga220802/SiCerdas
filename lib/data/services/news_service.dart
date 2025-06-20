import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/data/services/refactor_news_api_services.dart';

class NewsService {
  final String _baseUrl = 'http://45.149.187.204:3000/api';
  final CustomApiService _customApiService = CustomApiService();

  // Metode untuk mengambil SEMUA berita (endpoint publik, tidak memerlukan token)
  Future<List<NewsModel>> getNews() async {
    final uri = Uri.parse('$_baseUrl/news'); // Endpoint publik

    try {
      final response = await http.get(uri); // Tidak ada header Authorization

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);

        final body = decodedResponse['body'];
        if (body != null && body['success'] == true) {
          final List<dynamic> articlesJson = body['data'];
          return articlesJson.map((json) => NewsModel.fromCustomApiJson(json)).toList();
        } else {
          throw Exception('Gagal memuat data berita publik: ${body['message']}');
        }
      } else {
        throw Exception(
          'Gagal memuat berita publik. Kode status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error di NewsService (public endpoint): $e');
      rethrow;
    }
  }

  // Metode untuk mengambil berita milik pengguna (endpoint otentikasi, memerlukan token)
  Future<List<NewsModel>> getMyNews() async {
    // 1. Dapatkan token JWT dari layanan API kustom
    final token = await _customApiService.getToken();

    if (token == null) {
      // Jika token tidak valid (misal, belum login atau sesi habis), lemparkan exception
      throw Exception('Sesi tidak valid. Silakan login kembali untuk melihat berita Anda.');
    }

    // 2. Siapkan header dengan token Authorization
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

    // 3. Bangun URI untuk endpoint /author/news (untuk berita milik pengguna)
    final uri = Uri.parse('$_baseUrl/author/news');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);

        final body = decodedResponse['body'];
        if (body != null && body['success'] == true) {
          final List<dynamic> articlesJson = body['data'];
          return articlesJson.map((json) => NewsModel.fromCustomApiJson(json)).toList();
        } else {
          throw Exception('Gagal memuat berita Anda: ${body['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir saat memuat berita Anda. Silakan login kembali.');
      } else {
        throw Exception(
          'Gagal memuat berita Anda. Kode status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error di NewsService (authenticated endpoint): $e');
      rethrow;
    }
  }
}
