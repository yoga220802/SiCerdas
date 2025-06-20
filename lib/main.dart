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
import 'package:project_sicerdas/features/search/controllers/news_search_controller.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables and initialize Firebase
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);

  // Set device orientation to portrait mode
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
        ChangeNotifierProvider(create: (_) => NewsSearchController()),
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

// AuthWrapper directs users to the appropriate screen based on authentication status.
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

    // Check if the user is already authenticated
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

  // Handle authentication state changes
  void _onAuthChange() {
    if (_isAuthLoading && mounted) {
      setState(() {
        _isAuthLoading = false;
      });
    }

    if (_authController.userModel != null) {
      // Navigate to MainScreen if user is authenticated
      if (ModalRoute.of(context)?.settings.name != '/') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } else {
      // Navigate to AuthScreen if user is not authenticated
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

    // Display appropriate screen based on authentication status
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        if (authController.userModel != null) {
          return const MainScreen();
        } else {
          return const SplashScreen();
        }
      },
    );
  }
}
