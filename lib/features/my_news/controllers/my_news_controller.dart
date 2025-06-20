import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/data/services/news_service.dart';
import 'package:project_sicerdas/data/services/chat_service.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyNewsController extends ChangeNotifier {
  final NewsService _newsService = NewsService();
  final ChatService _chatService = ChatService();

  late AuthController _authController;

  late final CloudinaryPublic _cloudinary;
  final String _cloudinaryNewsUploadPreset = 'sicerdas_news_images';

  List<NewsModel> _myNews = [];
  List<NewsModel> get myNews => _myNews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isGeneratingSummary = false;
  bool get isGeneratingSummary => _isGeneratingSummary;

  bool _isUploadingImage = false;
  bool get isUploadingImage => _isUploadingImage;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  MyNewsController() {
    final cloudinaryUrl = dotenv.env['CLOUDINARY_URL'];
    if (cloudinaryUrl == null || !cloudinaryUrl.contains('@')) {
      throw Exception("CLOUDINARY_URL tidak ditemukan atau tidak valid di .env");
    }
    final cloudName = cloudinaryUrl.split('@').last;
    _cloudinary = CloudinaryPublic(cloudName, _cloudinaryNewsUploadPreset, cache: true);
  }

  void setAuthController(AuthController authController) {
    if (!_authControllerInitialized || _authController != authController) {
      _authController = authController;
      _authControllerInitialized = true;
    }
  }

  bool _authControllerInitialized = false;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setGeneratingSummary(bool generating) {
    _isGeneratingSummary = generating;
    notifyListeners();
  }

  void _setUploadingImage(bool uploading) {
    _isUploadingImage = uploading;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void setSuccessMessage(String? message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  Future<void> fetchMyNews() async {
    _setLoading(true);
    setErrorMessage(null);
    try {
      if (!_authControllerInitialized || _authController.currentUser == null) {
        setErrorMessage('Anda harus login untuk melihat berita Anda.');
        _myNews = [];
        return;
      }
      _myNews = await _newsService.getMyNews();
      _myNews.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    } catch (e) {
      setErrorMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createNews(NewsModel news) async {
    _setLoading(true);
    setErrorMessage(null);
    setSuccessMessage(null);
    try {
      await _newsService.createNews(news);
      setSuccessMessage('Berita berhasil dibuat!');
      await fetchMyNews();
      return true;
    } catch (e) {
      setErrorMessage('Gagal membuat berita: ${e.toString().replaceFirst('Exception: ', '')}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateNews(NewsModel news) async {
    _setLoading(true);
    setErrorMessage(null);
    setSuccessMessage(null);
    try {
      await _newsService.updateNews(news);
      setSuccessMessage('Berita berhasil diperbarui!');
      await fetchMyNews();
      return true;
    } catch (e) {
      setErrorMessage('Gagal memperbarui berita: ${e.toString().replaceFirst('Exception: ', '')}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteNews(String newsId) async {
    _setLoading(true);
    setErrorMessage(null);
    setSuccessMessage(null);
    try {
      await _newsService.deleteNews(newsId);
      setSuccessMessage('Berita berhasil dihapus!');
      await fetchMyNews();
      return true;
    } catch (e) {
      setErrorMessage('Gagal menghapus berita: ${e.toString().replaceFirst('Exception: ', '')}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> togglePublishStatus(String newsId, bool isPublished) async {
    _setLoading(true);
    setErrorMessage(null);
    setSuccessMessage(null);
    try {
      await _newsService.togglePublishStatus(newsId, isPublished);
      setSuccessMessage('Status berita berhasil diubah!');
      await fetchMyNews();
      return true;
    } catch (e) {
      setErrorMessage(
        'Gagal mengubah status publish: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String> generateSummaryFromContent(String content) async {
    _setGeneratingSummary(true);
    setErrorMessage(null);
    try {
      if (content.trim().isEmpty) {
        setErrorMessage('Konten berita tidak boleh kosong untuk membuat ringkasan.');
        return '';
      }
      final prompt =
          "Tolong ringkas isi berita berikut dalam 2-3 kalimat dan gunakan bahasa yang mudah dimengerti:\n\n---\n$content\n---";
      final summary = await _chatService.sendMessage(prompt);
      setSuccessMessage('Ringkasan berhasil dibuat!');
      return summary;
    } catch (e) {
      setErrorMessage('Gagal membuat ringkasan: ${e.toString()}');
      return '';
    } finally {
      _setGeneratingSummary(false);
    }
  }

  Future<String> uploadNewsImageAndGetUrl() async {
    final ImagePicker picker = ImagePicker();
    final currentUser = _authController.currentUser;

    if (currentUser == null) {
      setErrorMessage('Anda harus login untuk mengunggah gambar.');
      return '';
    }

    try {
      _setUploadingImage(true);
      setErrorMessage(null);
      setSuccessMessage(null);

      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        setSuccessMessage('Pemilihan gambar dibatalkan.');
        return '';
      }

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'sicerdas_news_images_by_user/${currentUser.uid}',
        ),
      );

      final String imageUrl = response.secureUrl;
      setSuccessMessage('Gambar berhasil diunggah!');
      return imageUrl;
    } on CloudinaryException catch (e) {
      setErrorMessage('Gagal mengunggah gambar berita: ${e.message}');
      print('Cloudinary News Image Error: ${e.message}');
      return '';
    } catch (e) {
      setErrorMessage('Terjadi kesalahan saat memilih atau mengunggah gambar: $e');
      print('General News Image Upload Error: $e');
      return '';
    } finally {
      _setUploadingImage(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
