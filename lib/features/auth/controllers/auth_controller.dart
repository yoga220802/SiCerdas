import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_sicerdas/data/models/user_model.dart';
import 'package:project_sicerdas/data/services/firebase_db_service.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDbProvider _dbProvider = FirebaseDbProvider();

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
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("Login berhasil untuk: $email");
      success = true;
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
        // Update display name di Firebase Auth (jika diperlukan langsung)
        // await userCredential.user!.updateDisplayName(username);
        // await userCredential.user!.reload(); // Reload user untuk mendapatkan data terbaru

        // Buat profil user di Realtime Database
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
      await _auth.signOut();
      print("User logged out");
    } catch (e) {
      print("Logout error: $e");
    } finally {
      _setLoading(false);
    }
  }
}
