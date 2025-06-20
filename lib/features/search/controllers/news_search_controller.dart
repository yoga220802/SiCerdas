import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/data/services/news_service.dart';

class NewsSearchController extends ChangeNotifier {
  final NewsService _newsService = NewsService();

  List<NewsModel> _allPublicNews = [];
  List<NewsModel> _trendingNews = [];
  List<NewsModel> _searchResults = [];

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoadingTrending = false;
  bool get isLoadingTrending => _isLoadingTrending;

  bool _isLoadingSearch = false;
  bool get isLoadingSearch => _isLoadingSearch;

  String? _errorMessageTrending;
  String? get errorMessageTrending => _errorMessageTrending;

  String? _errorMessageSearch;
  String? get errorMessageSearch => _errorMessageSearch;

  List<NewsModel> get trendingNews => _trendingNews;
  List<NewsModel> get searchResults => _searchResults;

  bool _isInitializing = false;

  NewsSearchController();

  void _safeNotifyListeners() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!hasListeners) return;
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  void initializeController() {
    if (!_isLoadingTrending && _allPublicNews.isEmpty && !_isInitializing) {
      _isInitializing = true;
      fetchTrendingNews().then((_) {
        _isInitializing = false;
      });
    }
  }

  void _setLoadingTrending(bool loading) {
    _isLoadingTrending = loading;
    _safeNotifyListeners();
  }

  void _setLoadingSearch(bool loading) {
    _isLoadingSearch = loading;
    _safeNotifyListeners();
  }

  void _setErrorMessageTrending(String? message) {
    _errorMessageTrending = message;
    _safeNotifyListeners();
  }

  void _setErrorMessageSearch(String? message) {
    _errorMessageSearch = message;
    _safeNotifyListeners();
  }

  Future<void> fetchTrendingNews() async {
    _setLoadingTrending(true);
    _setErrorMessageTrending(null);
    try {
      _allPublicNews = await _newsService.getNews();
      _trendingNews = List.from(_allPublicNews)..sort((a, b) => b.viewCount.compareTo(a.viewCount));
      _trendingNews = _trendingNews.take(5).toList();
    } catch (e) {
      _setErrorMessageTrending(
        'Gagal memuat trending topik: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      _trendingNews = [];
    } finally {
      _setLoadingTrending(false);
    }
  }

  void searchNews(String query) {
    _searchQuery = query.trim();
    _setErrorMessageSearch(null);

    if (_searchQuery.isEmpty) {
      _searchResults = [];
      _safeNotifyListeners();
      return;
    }

    _setLoadingSearch(true);

    try {
      _searchResults =
          _allPublicNews.where((news) {
            final lowerCaseQuery = _searchQuery.toLowerCase();
            return news.title.toLowerCase().contains(lowerCaseQuery) ||
                news.summary.toLowerCase().contains(lowerCaseQuery) ||
                news.content.toLowerCase().contains(lowerCaseQuery) ||
                news.category.toLowerCase().contains(lowerCaseQuery) ||
                news.tags.any((tag) => tag.toLowerCase().contains(lowerCaseQuery));
          }).toList();
    } catch (e) {
      _setErrorMessageSearch('Terjadi kesalahan saat mencari: ${e.toString()}');
      _searchResults = [];
    } finally {
      _setLoadingSearch(false);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _setErrorMessageSearch(null);
    _safeNotifyListeners();
  }
}
