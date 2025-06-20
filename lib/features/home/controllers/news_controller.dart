import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/data/services/news_service.dart';

class NewsController extends ChangeNotifier {
  final NewsService _newsService = NewsService();

  // State
  bool _isLoading = true;
  String? _errorMessage;
  List<NewsModel> _allNews = [];
  List<String> _categories = [];
  String _selectedCategory = 'Semua';

  // Getters untuk UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;

  // Berita yang difilter berdasarkan kategori
  List<NewsModel> get filteredNews {
    if (_selectedCategory == 'Semua') {
      return _allNews;
    }
    return _allNews.where((news) => news.category == _selectedCategory).toList();
  }

  // Constructor tanpa pemanggilan fetchInitialNews()
  NewsController();

  // Mengambil data awal dan membangun daftar kategori
  Future<void> fetchInitialNews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Ambil semua berita dari service
      final newsList = await _newsService.getNews();
      _allNews = newsList;

      // Ekstrak kategori unik dari berita
      final extractedCategories = _allNews.map((news) => news.category).toSet().toList();

      // Tambahkan 'Semua' sebagai kategori pertama dan urutkan
      _categories = ['Semua', ...extractedCategories]..sort((a, b) {
        if (a == 'Semua') return -1;
        if (b == 'Semua') return 1;
        return a.compareTo(b);
      });

      _selectedCategory = 'Semua';
    } catch (e) {
      _errorMessage = e.toString();
      print('Error di NewsController: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mengubah kategori yang dipilih
  void selectCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }
}
