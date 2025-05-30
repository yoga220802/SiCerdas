import 'package:flutter/material.dart';
// TODO: Import Firebase Auth dan service terkait jika sudah dibuat

class AuthController extends ChangeNotifier {
  // Status loading untuk UI
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Pesan error untuk ditampilkan di UI
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // TODO: Tambahkan instance dari AuthService/AuthProvider
  // final AuthService _authService = AuthService();

  // Method untuk mengubah status loading dan memberi notifikasi ke listener
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Method untuk menetapkan pesan error dan memberi notifikasi
  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Fungsi untuk login
  Future<void> loginUser({required String email, required String password}) async {
    _setLoading(true);
    _setError(null); // Bersihkan error sebelumnya

    try {
      // TODO: Implementasi logika login dengan Firebase Auth
      // Contoh: await _authService.signInWithEmailAndPassword(email, password);
      await Future.delayed(const Duration(seconds: 2)); // Simulasi network call

      if (email == "test@example.com" && password == "password") {
        print("Login berhasil!");
        // Navigasi atau tindakan lain setelah login berhasil
      } else {
        throw Exception("Email atau password salah.");
      }
    } catch (e) {
      _setError(e.toString());
      print("Login error: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Fungsi untuk register
  Future<void> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // TODO: Implementasi logika register dengan Firebase Auth
      // Contoh: await _authService.createUserWithEmailAndPassword(email, password);
      // Setelah itu, simpan username ke Firestore atau Realtime Database jika perlu
      await Future.delayed(const Duration(seconds: 2)); // Simulasi network call
      print("Register berhasil untuk: $username, $email");
    } catch (e) {
      _setError(e.toString());
      print("Register error: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Fungsi untuk lupa password
  Future<void> forgotPassword({required String email}) async {
    _setLoading(true);
    _setError(null);

    try {
      // TODO: Implementasi logika lupa password dengan Firebase Auth
      // Contoh: await _authService.sendPasswordResetEmail(email);
      await Future.delayed(const Duration(seconds: 2)); // Simulasi network call
      print("Email reset password dikirim ke: $email");
    } catch (e) {
      _setError(e.toString());
      print("Forgot password error: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Fungsi untuk logout
  Future<void> logoutUser() async {
    _setLoading(true);
    try {
      // TODO: Implementasi logika logout
      // await _authService.signOut();
      await Future.delayed(const Duration(seconds: 1));
      print("User logged out");
    } catch (e) {
      print("Logout error: $e");
      // Tidak perlu set error di UI untuk logout biasanya
    } finally {
      _setLoading(false);
    }
  }
}
