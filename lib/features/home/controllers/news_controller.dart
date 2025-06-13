import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/data/services/news_service.dart';

class NewsController extends ChangeNotifier {
  final NewsService _newsService = NewsService();

  // UBAH: dari List<ApiSource> menjadi Map<String, List<ApiSource>>
  final Map<String, List<ApiSource>> _sourcesByCategory = {};
  Map<String, List<ApiSource>> get sourcesByCategory => _sourcesByCategory;

  final Map<String, List<NewsArticle>> _articlesByCategory = {};
  Map<String, List<NewsArticle>> get articlesByCategory => _articlesByCategory;

  final Map<String, bool> _isLoadingByCategory = {};
  bool isLoadingForCategory(String category) => _isLoadingByCategory[category] ?? false;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // UBAH: fetchInitialData sekarang hanya memanggil fetchNewsForCategory
  Future<void> fetchInitialData(String initialCategory) async {
    await fetchNewsForCategory(initialCategory);
  }

  // HAPUS FUNGSI fetchSources() YANG LAMA

  // UBAH: fetchNewsForCategory sekarang mengambil berita DAN sumber berita
  Future<void> fetchNewsForCategory(String category) async {
    final lowerCaseCategory = category.toLowerCase();

    // Jangan fetch ulang jika data sudah ada
    if (_articlesByCategory.containsKey(lowerCaseCategory)) return;

    _isLoadingByCategory[lowerCaseCategory] = true;
    _setError(null);
    notifyListeners();

    try {
      // Kita akan fetch berita dan source secara bersamaan untuk efisiensi
      final results = await Future.wait([
        // Panggilan untuk artikel
        lowerCaseCategory == 'semua'
            ? _newsService.getTopHeadlines(country: 'us')
            : _newsService.getNewsByCategory(category: lowerCaseCategory),

        // Panggilan untuk source berita sesuai kategori
        _newsService.getSources(
          category: lowerCaseCategory == 'semua' ? null : lowerCaseCategory,
          language: 'en',
        ),
      ]);

      // Hasil pertama adalah list artikel
      final List<NewsArticle> news = results[0] as List<NewsArticle>;
      _articlesByCategory[lowerCaseCategory] = news;

      // Hasil kedua adalah list source
      final List<ApiSource> sources =
          (results[1] as List<ApiSource>).where((s) => s.url != null).take(20).toList();
      _sourcesByCategory[lowerCaseCategory] = sources;
    } catch (e) {
      _setError(e.toString());
      print('Error fetching data for $category: $e');
    } finally {
      _isLoadingByCategory[lowerCaseCategory] = false;
      notifyListeners();
    }
  }
}
