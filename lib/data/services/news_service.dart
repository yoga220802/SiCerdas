import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/data/services/refactor_news_api_services.dart';

class NewsService {
  final String _baseUrl = 'http://45.149.187.204:3000/api';
  final CustomApiService _customApiService = CustomApiService();

  // Metode untuk mengambil semua berita (endpoint publik, tidak memerlukan token)
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
    // Dapatkan token JWT dari layanan API kustom
    final token = await _customApiService.getToken();

    if (token == null) {
      throw Exception('Sesi tidak valid. Silakan login kembali untuk melihat berita Anda.');
    }

    // Siapkan header dengan token Authorization
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

    // Bangun URI untuk endpoint /author/news (untuk berita milik pengguna)
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

  // Metode untuk membuat berita baru
  Future<void> createNews(NewsModel news) async {
    final token = await _customApiService.getToken();
    if (token == null) {
      throw Exception('Sesi tidak valid. Silakan login kembali untuk membuat berita.');
    }

    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
    final uri = Uri.parse('$_baseUrl/author/news'); // Endpoint untuk membuat berita

    // Konversi featuredImageUrl dari string kosong menjadi null jika perlu
    final String? featuredImageUrlToSend =
        (news.featuredImageUrl != null && news.featuredImageUrl!.isNotEmpty)
            ? news.featuredImageUrl
            : null;

    // Tidak lagi memfilter tags kosong, kirim apa adanya dari news.tags
    final List<String> tagsToSend = news.tags;

    // Tambahkan log untuk featured_image_url dan tags
    print('NewsService: Mengirim featuredImageUrl (create): $featuredImageUrlToSend');
    print('NewsService: Mengirim tags (create): $tagsToSend');

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'title': news.title,
          'summary': news.summary,
          'content': news.content,
          'featuredImageUrl': featuredImageUrlToSend,
          'category': news.category,
          'tags': tagsToSend,
          'isPublished': news.isPublished,
        }),
      );

      // Tambahkan log untuk response dari service
      print('NewsService (createNews) Response Status: ${response.statusCode}');
      print('NewsService (createNews) Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        final body = decodedResponse['body'];
        if (body != null && body['success'] == true) {
          print('Berita berhasil dibuat: ${body['message']}');
        } else {
          throw Exception('Gagal membuat berita: ${body['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir saat membuat berita. Silakan login kembali.');
      } else {
        throw Exception(
          'Gagal membuat berita. Kode status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error di NewsService (createNews): $e');
      rethrow;
    }
  }

  // Metode untuk memperbarui berita
  Future<void> updateNews(NewsModel news) async {
    final token = await _customApiService.getToken();
    if (token == null) {
      throw Exception('Sesi tidak valid. Silakan login kembali untuk mengedit berita.');
    }

    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
    final uri = Uri.parse('$_baseUrl/author/news/${news.id}'); // Endpoint untuk mengedit berita

    // Konversi featuredImageUrl dari string kosong menjadi null jika perlu
    final String? featuredImageUrlToSend =
        (news.featuredImageUrl != null && news.featuredImageUrl!.isNotEmpty)
            ? news.featuredImageUrl
            : null;

    // Tidak lagi memfilter tags kosong, kirim apa adanya dari news.tags
    final List<String> tagsToSend = news.tags;

    // Tambahkan log untuk featured_image_url dan tags
    print('NewsService: Mengirim featuredImageUrl (update): $featuredImageUrlToSend');
    print('NewsService: Mengirim tags (update): $tagsToSend');

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode({
          'title': news.title,
          'summary': news.summary,
          'content': news.content,
          'featuredImageUrl': featuredImageUrlToSend,
          'category': news.category,
          'tags': tagsToSend,
          'isPublished': news.isPublished,
        }),
      );

      // Tambahkan log untuk response dari service
      print('NewsService (updateNews) Response Status: ${response.statusCode}');
      print('NewsService (updateNews) Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        final body = decodedResponse['body'];
        if (body != null && body['success'] == true) {
          print('Berita berhasil diperbarui: ${body['message']}');
        } else {
          throw Exception('Gagal memperbarui berita: ${body['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir saat mengedit berita. Silakan login kembali.');
      } else {
        throw Exception(
          'Gagal memperbarui berita. Kode status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error di NewsService (updateNews): $e');
      rethrow;
    }
  }

  // Metode untuk menghapus berita
  Future<void> deleteNews(String newsId) async {
    final token = await _customApiService.getToken();
    if (token == null) {
      throw Exception('Sesi tidak valid. Silakan login kembali untuk menghapus berita.');
    }

    final headers = {'Authorization': 'Bearer $token'}; // Tidak perlu Content-Type untuk DELETE
    final uri = Uri.parse('$_baseUrl/author/news/$newsId'); // Endpoint untuk menghapus berita

    try {
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        final body = decodedResponse['body'];
        if (body != null && body['success'] == true) {
          print('Berita berhasil dihapus: ${body['message']}');
        } else {
          throw Exception('Gagal menghapus berita: ${body['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi Anda telah berakhir saat menghapus berita. Silakan login kembali.');
      } else {
        throw Exception(
          'Gagal menghapus berita. Kode status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error di NewsService (deleteNews): $e');
      rethrow;
    }
  }

  // Metode untuk mengubah status publish/unpublish
  Future<void> togglePublishStatus(String newsId, bool isPublished) async {
    final token = await _customApiService.getToken();
    if (token == null) {
      throw Exception('Sesi tidak valid. Silakan login kembali untuk mengubah status berita.');
    }

    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
    final uri = Uri.parse('$_baseUrl/author/news/$newsId');

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode({'isPublished': isPublished}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        final body = decodedResponse['body'];
        if (body != null && body['success'] == true) {
          print('Status berita berhasil diubah: ${body['message']}');
        } else {
          throw Exception('Gagal mengubah status berita: ${body['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception(
          'Sesi Anda telah berakhir saat mengubah status berita. Silakan login kembali.',
        );
      } else {
        throw Exception(
          'Gagal mengubah status berita. Kode status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('Error di NewsService (togglePublishStatus): $e');
      rethrow;
    }
  }
}
