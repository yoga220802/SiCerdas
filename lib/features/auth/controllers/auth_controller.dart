import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_sicerdas/data/models/user_model.dart';
import 'package:project_sicerdas/data/services/firebase_db_service.dart';
import 'package:project_sicerdas/data/services/refactor_news_api_services.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDbProvider _dbProvider = FirebaseDbProvider();
  final CustomApiService _customApiService = CustomApiService(); // <-- INSTANCE BARU

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    // notifyListeners();
  }

  Future<bool> loginUser({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);
    bool success = false;
    try {
      // Langkah 1: Login ke Firebase
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("Login Firebase berhasil untuk: $email");

      // Langkah 2: Login ke API Kustom
      final bool customApiLoginSuccess = await _customApiService.loginToCustomApi();

      if (customApiLoginSuccess) {
        // Jika kedua login berhasil
        success = true;
      } else {
        // Jika login API kustom gagal, logout dari Firebase agar state konsisten
        await _auth.signOut();
        _setError('Gagal terhubung ke server berita.');
        print("Login API Kustom gagal, Firebase sign out dijalankan.");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _setError('User tidak ditemukan untuk email tersebut.');
      } else if (e.code == 'wrong-password') {
        _setError('Password salah.');
      } else {
        _setError('Gagal login: ${e.message}');
      }
      print("Login error: ${_errorMessage}");
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      print("Login error: ${_errorMessage}");
    } finally {
      _setLoading(false);
    }
    return success;
  }

  Future<bool> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    bool success = false;

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(username);
        await userCredential.user!.reload();

        final newUser = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          displayName: username,
          createdAt: DateTime.now(),
        );
        await _dbProvider.createUserProfile(newUser);

        print("Register berhasil untuk: $username, $email. Profil dibuat.");
        success = true;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _setError('Password terlalu lemah.');
      } else if (e.code == 'email-already-in-use') {
        _setError('Email sudah digunakan oleh akun lain.');
      } else {
        _setError('Gagal register: ${e.message}');
      }
      print("Register error: ${_errorMessage}");
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      print("Register error: ${_errorMessage}");
    } finally {
      _setLoading(false);
    }
    return success;
  }

  // Metode forgotPassword tidak perlu diubah
  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    _setError(null);
    bool success = false;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Email reset password dikirim ke: $email");
      success = true;
    } on FirebaseAuthException catch (e) {
      _setError('Gagal mengirim email reset: ${e.message}');
      print("Forgot password error: ${_errorMessage}");
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      print("Forgot password error: ${_errorMessage}");
    } finally {
      _setLoading(false);
    }
    return success;
  }

  Future<void> logoutUser() async {
    _setLoading(true);
    try {
      // Logout dari kedua layanan
      await _auth.signOut();
      await _customApiService.logout();
      print("User logged out dari Firebase dan token kustom dihapus");
    } catch (e) {
      print("Logout error: $e");
    } finally {
      _setLoading(false);
    }
  }
}
