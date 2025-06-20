import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/user_model.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart';
import 'package:project_sicerdas/data/services/firebase_db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileController extends ChangeNotifier {
  final AuthController authController;
  final FirebaseDbProvider _dbProvider = FirebaseDbProvider();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance Cloudinary untuk unggah gambar
  late final CloudinaryPublic _cloudinary;
  final String _cloudinaryUploadPreset = 'sicerdas_upload_preset';

  // TextEditingControllers untuk form
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;

  // State untuk loading dan upload foto
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploadingPhoto = false;
  bool get isUploadingPhoto => _isUploadingPhoto;

  // Pesan error dan sukses
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  ProfileController({required this.authController}) {
    // Inisialisasi Cloudinary dari .env
    final cloudinaryUrl = dotenv.env['CLOUDINARY_URL'];
    if (cloudinaryUrl == null || !cloudinaryUrl.contains('@')) {
      throw Exception("CLOUDINARY_URL tidak valid di .env");
    }
    final cloudName = cloudinaryUrl.split('@').last;
    _cloudinary = CloudinaryPublic(cloudName, _cloudinaryUploadPreset, cache: true);

    // Inisialisasi controller dengan data pengguna saat ini
    final user = authController.userModel;
    usernameController = TextEditingController(text: user?.displayName ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();

    // Tambahkan listener untuk perubahan userModel
    authController.addListener(_onAuthChange);
  }

  void _onAuthChange() {
    // Perbarui TextControllers jika userModel berubah
    final user = authController.userModel;
    if (user != null) {
      usernameController.text = user.displayName ?? '';
      emailController.text = user.email;
    } else {
      usernameController.clear();
      emailController.clear();
    }
    currentPasswordController.clear();
    newPasswordController.clear();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUploadingPhoto(bool uploading) {
    _isUploadingPhoto = uploading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String? message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  // Pilih dan unggah gambar profil ke Cloudinary
  Future<void> uploadProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      _setError('Tidak ada pengguna yang masuk.');
      return;
    }

    try {
      _setUploadingPhoto(true);
      _setError(null);
      _setSuccess(null);

      // Pilih gambar dari galeri
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        _setSuccess('Pemilihan gambar dibatalkan.');
        _setUploadingPhoto(false);
        return;
      }

      // Unggah gambar ke Cloudinary
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'sicerdas_profile_pics/${currentUser.uid}',
        ),
      );

      final String imageUrl = response.secureUrl;

      // Perbarui URL foto di Firebase Realtime Database
      await _dbProvider.updateUserProfile(currentUser.uid, {'photoUrl': imageUrl});

      // Perbarui userModel di AuthController
      await authController.getCurrentUser();

      _setSuccess('Foto profil berhasil diperbarui!');
    } on CloudinaryException catch (e) {
      _setError('Gagal mengunggah foto ke Cloudinary: ${e.message}');
    } catch (e) {
      _setError('Terjadi kesalahan saat memilih atau mengunggah gambar: $e');
    } finally {
      _setUploadingPhoto(false);
    }
  }

  // Perbarui profil pengguna (username, email, password)
  Future<void> updateProfile() async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _setError('Tidak ada pengguna yang masuk.');
      _setLoading(false);
      return;
    }

    try {
      // Update username di Realtime Database
      await _dbProvider.updateUserProfile(currentUser.uid, {
        'displayName': usernameController.text.trim(),
      });

      // Update email jika berubah
      if (emailController.text.trim() != currentUser.email) {
        if (currentPasswordController.text.isEmpty) {
          _setError('Untuk mengubah email, Anda harus memasukkan password saat ini.');
          _setLoading(false);
          return;
        }

        // Re-authenticate sebelum update email
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentPasswordController.text.trim(),
        );
        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.updateEmail(emailController.text.trim());
        await _dbProvider.updateUserProfile(currentUser.uid, {
          'email': emailController.text.trim(),
        });
      }

      // Update password jika ada
      if (newPasswordController.text.trim().isNotEmpty) {
        if (currentPasswordController.text.isEmpty) {
          _setError('Untuk mengubah password, Anda harus memasukkan password saat ini.');
          _setLoading(false);
          return;
        }
        if (newPasswordController.text.trim().length < 6) {
          _setError('Password baru minimal 6 karakter.');
          _setLoading(false);
          return;
        }

        // Re-authenticate sebelum update password
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentPasswordController.text.trim(),
        );
        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.updatePassword(newPasswordController.text.trim());
      }

      // Perbarui userModel di AuthController
      await authController.getCurrentUser();
      _setSuccess('Profil berhasil diperbarui!');
      currentPasswordController.clear();
      newPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _setError('Untuk mengubah email atau password, Anda perlu login ulang.');
      } else if (e.code == 'wrong-password') {
        _setError('Password saat ini salah.');
      } else if (e.code == 'invalid-email') {
        _setError('Format email tidak valid.');
      } else if (e.code == 'email-already-in-use') {
        _setError('Email sudah digunakan oleh akun lain.');
      } else {
        _setError('Gagal memperbarui profil: ${e.message}');
      }
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    authController.removeListener(_onAuthChange);
    super.dispose();
  }
}
