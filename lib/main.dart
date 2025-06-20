import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:project_sicerdas/app/theme/app_theme.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart';
import 'package:project_sicerdas/features/auth/views/auth_screen.dart';
import 'package:project_sicerdas/features/home/controllers/news_controller.dart';
import 'package:project_sicerdas/features/main_screen.dart';
import 'package:project_sicerdas/features/onboarding/view/splash_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env"); // Memuat file konfigurasi lingkungan

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Inisialisasi Firebase

  await initializeDateFormatting('id_ID', null); // Inisialisasi format tanggal lokal

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]); // Mengatur orientasi layar ke potret

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()), // Provider untuk autentikasi
        ChangeNotifierProvider(create: (_) => NewsController()), // Provider untuk berita
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SICERDAS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Menggunakan tema aplikasi
      home: const AuthWrapper(), // Menggunakan AuthWrapper sebagai halaman awal
    );
  }
}

// AuthWrapper mengarahkan pengguna ke layar yang sesuai berdasarkan status autentikasi
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthLoading = true; // Flag untuk menunjukkan status loading autentikasi

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);

      authController.addListener(_onAuthChange); // Menambahkan listener untuk perubahan autentikasi

      if (authController.currentUser != null) {
        authController.getCurrentUser(); // Memuat data pengguna jika sudah login
      } else {
        if (mounted) {
          setState(() {
            _isAuthLoading = false; // Mengatur status loading ke false jika tidak ada pengguna
          });
        }
      }
    });
  }

  void _onAuthChange() {
    if (_isAuthLoading && mounted) {
      setState(() {
        _isAuthLoading = false; // Mengatur status loading ke false setelah autentikasi selesai
      });
    }
  }

  @override
  void dispose() {
    Provider.of<AuthController>(
      context,
      listen: false,
    ).removeListener(_onAuthChange); // Menghapus listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthLoading) {
      return const SplashScreen(); // Menampilkan SplashScreen selama autentikasi berlangsung
    }

    return Consumer<AuthController>(
      builder: (context, authController, child) {
        if (authController.userModel != null) {
          return const MainScreen(); // Mengarahkan ke MainScreen jika pengguna sudah login
        } else {
          return const AuthScreen(); // Mengarahkan ke AuthScreen jika pengguna belum login
        }
      },
    );
  }
}
