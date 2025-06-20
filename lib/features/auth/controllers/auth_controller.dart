import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_sicerdas/data/models/user_model.dart';
import 'package:project_sicerdas/data/services/firebase_db_service.dart';
import 'package:project_sicerdas/data/services/refactor_news_api_services.dart';
import 'dart:async';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDbProvider _dbProvider = FirebaseDbProvider();
  final CustomApiService _customApiService = CustomApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  late StreamSubscription<User?> _authStateSubscription;
  bool _isDisposed = false;

  // Constructor untuk inisialisasi listener status autentikasi.
  AuthController() {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      if (_isDisposed) return;

      if (user == null) {
        _userModel = null;
        _safeNotifyListeners();
      } else {
        if (_userModel == null || _userModel!.uid != user.uid) {
          getCurrentUser();
        } else {
          _safeNotifyListeners();
        }
      }
    });
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _safeNotifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    _safeNotifyListeners();
  }

  /// Mengambil profil pengguna dari Firebase.
  Future<void> getCurrentUser() async {
    if (_isDisposed) return;

    final user = _auth.currentUser;
    if (user != null) {
      try {
        _userModel = await _dbProvider.getUserProfile(user.uid);
        print("Data pengguna berhasil diambil: ${_userModel?.displayName}");
      } catch (e) {
        print("Gagal mendapatkan profil pengguna: $e");
        _setError("Gagal mendapatkan profil pengguna.");
        _userModel = null;
      } finally {
        _safeNotifyListeners();
      }
    } else {
      _userModel = null;
      _safeNotifyListeners();
    }
  }

  /// Login pengguna dengan Firebase dan API kustom.
  Future<bool> loginUser({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);
    bool success = false;
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Login Firebase berhasil untuk: $email");

      final bool customApiLoginSuccess = await _customApiService.loginToCustomApi();

      if (_isDisposed) return false;

      if (customApiLoginSuccess) {
        success = true;
      } else {
        await _auth.signOut();
        _setError('Gagal terhubung ke server berita. Silakan coba lagi.');
        print("Login API Kustom gagal, Firebase sign out dijalankan.");
      }
    } on FirebaseAuthException catch (e) {
      if (_isDisposed) return false;

      if (e.code == 'user-not-found') {
        _setError('User tidak ditemukan untuk email tersebut.');
      } else if (e.code == 'wrong-password') {
        _setError('Password salah.');
      } else if (e.code == 'invalid-email') {
        _setError('Format email tidak valid.');
      } else {
        _setError('Gagal login: ${e.message}');
      }
      print("Login error: ${_errorMessage}");
    } catch (e) {
      if (_isDisposed) return false;

      _setError('Terjadi kesalahan: ${e.toString()}');
      print("Login error: ${_errorMessage}");
    } finally {
      if (_isDisposed) return false;
      _setLoading(false);
    }
    return success;
  }

  /// Registrasi pengguna baru dengan Firebase.
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

      if (_isDisposed) return false;

      if (userCredential.user != null) {
        final newUser = UserModel(
          uid: userCredential.user!.uid,
          displayName: username,
          email: email,
          createdAt: DateTime.now(),
        );
        await _dbProvider.createUserProfile(newUser);

        _userModel = newUser;
        print("Register berhasil untuk: $username, $email. Profil dibuat.");
        success = true;
        _safeNotifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      if (_isDisposed) return false;

      if (e.code == 'weak-password') {
        _setError('Password terlalu lemah.');
      } else if (e.code == 'email-already-in-use') {
        _setError('Email sudah digunakan oleh akun lain.');
      } else {
        _setError('Gagal register: ${e.message}');
      }
      print("Register error: ${_errorMessage}");
    } catch (e) {
      if (_isDisposed) return false;

      _setError('Terjadi kesalahan: ${e.toString()}');
      print("Register error: ${_errorMessage}");
    } finally {
      if (_isDisposed) return false;
      _setLoading(false);
    }
    return success;
  }

  /// Mengirim email reset password.
  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    _setError(null);
    bool success = false;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Email reset password dikirim ke: $email");
      success = true;
    } on FirebaseAuthException catch (e) {
      if (_isDisposed) return false;

      _setError('Gagal mengirim email reset: ${e.message}');
      print("Forgot password error: ${_errorMessage}");
    } catch (e) {
      if (_isDisposed) return false;

      _setError('Terjadi kesalahan: ${e.toString()}');
      print("Forgot password error: ${_errorMessage}");
    } finally {
      if (_isDisposed) return false;
      _setLoading(false);
    }
    return success;
  }

  /// Logout pengguna dari Firebase dan API kustom.
  Future<void> logoutUser() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      await _customApiService.logout();
      _userModel = null;
      print("User logged out dari Firebase dan token kustom dihapus");
    } catch (e) {
      print("Logout error: $e");
    } finally {
      if (_isDisposed) return;
      _setLoading(false);
      _safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authStateSubscription.cancel();
    super.dispose();
  }
}
