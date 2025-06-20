import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/data/services/refactor_news_api_services.dart';

class NewsService {
  final String _baseUrl = 'http://45.149.187.204:3000/api';
  final CustomApiService _customApiService = CustomApiService();

  // Method untuk mengambil berita dari backend kustom
  Future<List<NewsModel>> getNews() async {
    // Dapatkan token JWT dari layanan API kustom
    final token = await _customApiService.getToken();

    if (token == null) {
      throw Exception('Sesi tidak valid. Silakan login kembali.');
    }

    // Siapkan header dengan token Authorization
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

    // Bangun URI untuk endpoint /author/news
    var uri = Uri.parse('$_baseUrl/author/news');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);

        // Navigasi ke dalam struktur JSON yang benar
        final body = decodedResponse['body'];
        if (body != null && body['success'] == true) {
          final List<dynamic> articlesJson = body['data'];
          // Ubah setiap item JSON menjadi objek NewsModel
          return articlesJson.map((json) => NewsModel.fromCustomApiJson(json)).toList();
        } else {
          throw Exception('Gagal memuat data berita: ${body['message']}');
        }
      } else if (response.statusCode == 401) {
        // Token tidak valid atau kedaluwarsa
        throw Exception('Sesi Anda telah berakhir. Silakan login kembali.');
      } else {
        // Error server lainnya
        throw Exception('Gagal memuat berita. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error di NewsService: $e');
      // Lemparkan kembali error agar UI bisa menanganinya
      rethrow;
    }
  }
}
