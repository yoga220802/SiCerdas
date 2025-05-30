import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_sicerdas/app/theme/app_theme.dart';
import 'package:project_sicerdas/features/auth/views/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SICERDAS',
      debugShowCheckedModeBanner: true,
      theme: AppTheme.lightTheme,
      home: const AuthScreen(),
    );
  }
}
