import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/data/services/news_service.dart';

class NewsController extends ChangeNotifier {
  final NewsService _newsService = NewsService();

  // State
  bool _isLoading = true; // Status loading data
  String? _errorMessage; // Pesan error jika terjadi kesalahan
  List<NewsModel> _allNews = []; // Semua berita yang diambil
  List<String> _categories = []; // Daftar kategori berita
  String _selectedCategory = 'Semua'; // Kategori yang dipilih

  // Getters untuk diakses oleh UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;

  // Getter untuk berita yang sudah difilter berdasarkan kategori
  List<NewsModel> get filteredNews {
    if (_selectedCategory == 'Semua') {
      return _allNews;
    }
    return _allNews.where((news) => news.category == _selectedCategory).toList();
  }

  // Constructor untuk langsung memuat data saat controller dibuat
  NewsController() {
    fetchInitialNews();
  }

  // Mengambil data awal dan membangun daftar kategori
  Future<void> fetchInitialNews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Panggil service untuk mendapatkan semua berita
      final newsList = await _newsService.getNews();
      _allNews = newsList;

      // Ekstrak kategori unik dari daftar berita
      final extractedCategories = _allNews.map((news) => news.category).toSet().toList();

      // Tambahkan 'Semua' sebagai kategori pertama dan urutkan
      _categories = ['Semua', ...extractedCategories]..sort((a, b) {
        if (a == 'Semua') return -1;
        if (b == 'Semua') return 1;
        return a.compareTo(b);
      });

      _selectedCategory = 'Semua';
    } catch (e) {
      _errorMessage = e.toString(); // Simpan pesan error jika terjadi kesalahan
    } finally {
      _isLoading = false;
      notifyListeners(); // Beri tahu UI bahwa data telah selesai dimuat
    }
  }

  // Mengubah kategori yang dipilih
  void selectCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners(); // Beri tahu UI bahwa kategori telah berubah
    }
  }
}
