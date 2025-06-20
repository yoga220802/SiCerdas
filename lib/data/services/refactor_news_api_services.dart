import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomApiService {
  final String _baseUrl = 'http://45.149.187.204:3000/api';
  static final CustomApiService _instance = CustomApiService._internal();

  factory CustomApiService() {
    return _instance;
  }

  CustomApiService._internal();

  String? _token;

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    return _token;
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<bool> loginToCustomApi() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': 'news@itg.ac.id', 'password': 'ITG#news'}),
      );

      print('Custom API Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Respons Body dari Custom API: ${response.body}');

        final Map<String, dynamic> decodedResponse = json.decode(response.body);

        final body = decodedResponse['body'];
        if (body != null && body is Map<String, dynamic>) {
          final data = body['data'];
          if (data != null && data is Map<String, dynamic>) {
            final token = data['token'];

            if (token != null && token is String) {
              await _saveToken(token);
              print('Custom API Login Berhasil, Token disimpan.');
              print('Token: $token');
              return true;
            }
          }
        }

        print('Custom API Login Gagal: Struktur JSON tidak sesuai atau token tidak ditemukan.');
        return false;
      } else {
        print('Custom API Login Gagal: Status Code ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error saat login ke API kustom: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    print('Token JWT lokal telah dihapus.');
  }
}
