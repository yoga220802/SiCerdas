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

  // Constructor untuk inisialisasi listener autentikasi
  AuthController() {
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _userModel = null; // Kosongkan userModel jika pengguna logout
        notifyListeners();
      } else {
        getCurrentUser(); // Ambil data pengguna jika login
      }
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Memberitahu UI tentang perubahan status loading
  }

  void _setError(String? message) {
    _errorMessage = message;
  }

  Future<void> getCurrentUser() async {
    if (_auth.currentUser != null &&
        (_userModel == null || _userModel!.uid != _auth.currentUser!.uid)) {
      try {
        _userModel = await _dbProvider.getUserProfile(_auth.currentUser!.uid);
      } catch (e) {
        _setError("Gagal mendapatkan profil pengguna.");
        _userModel = null;
      } finally {
        notifyListeners();
      }
    } else if (_auth.currentUser == null) {
      _userModel = null;
      notifyListeners();
    }
  }

  Future<bool> loginUser({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);
    bool success = false;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      final bool customApiLoginSuccess = await _customApiService.loginToCustomApi();

      if (customApiLoginSuccess) {
        await getCurrentUser();
        success = true;
      } else {
        await _auth.signOut();
        _setError('Gagal terhubung ke server berita.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _setError('User tidak ditemukan untuk email tersebut.');
      } else if (e.code == 'wrong-password') {
        _setError('Password salah.');
      } else {
        _setError('Gagal login: ${e.message}');
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
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
        final newUser = UserModel(
          uid: userCredential.user!.uid,
          displayName: username,
          email: email,
          createdAt: DateTime.now(),
        );
        await _dbProvider.createUserProfile(newUser);

        _userModel = newUser;
        success = true;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _setError('Password terlalu lemah.');
      } else if (e.code == 'email-already-in-use') {
        _setError('Email sudah digunakan oleh akun lain.');
      } else {
        _setError('Gagal register: ${e.message}');
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
    return success;
  }

  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    _setError(null);
    bool success = false;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      success = true;
    } on FirebaseAuthException catch (e) {
      _setError('Gagal mengirim email reset: ${e.message}');
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
    return success;
  }

  Future<void> logoutUser() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      await _customApiService.logout();
      _userModel = null;
    } catch (e) {
      // Tangani error logout jika diperlukan
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel(); // Batalkan subscription saat controller di-dispose
    super.dispose();
  }
}
