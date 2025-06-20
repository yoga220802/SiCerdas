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
import 'package:project_sicerdas/features/my_news/controllers/my_news_controller.dart';
import 'package:project_sicerdas/features/onboarding/view/splash_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => NewsController()),
        ChangeNotifierProvider(create: (_) => MyNewsController()),
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
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

/// AuthWrapper mengarahkan pengguna ke layar yang sesuai berdasarkan status autentikasi.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthLoading = true;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Provider.of<AuthController>(context, listen: false);
    _authController.addListener(_onAuthChange);

    if (_authController.currentUser != null) {
      _authController.getCurrentUser();
    } else {
      if (mounted) {
        setState(() {
          _isAuthLoading = false;
        });
      }
    }
  }

  void _onAuthChange() {
    if (_isAuthLoading && mounted) {
      setState(() {
        _isAuthLoading = false;
      });
    }

    if (_authController.userModel != null) {
      if (ModalRoute.of(context)?.settings.name != '/') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } else {
      if (ModalRoute.of(context)?.settings.name != '/') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthLoading) {
      return const SplashScreen();
    }

    return Consumer<AuthController>(
      builder: (context, authController, child) {
        if (authController.userModel != null) {
          return const MainScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
