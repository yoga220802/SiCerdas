/// file: lib/features/main_screen.dart
///
/// Layar utama yang mengatur Bottom Navigation Bar.
/// Mengganti tab "Bookmark" dengan tab "Account" (Berita Saya) untuk manajemen berita.
/// Memperbaiki ProviderNotFoundException dengan memastikan MyNewsController tersedia di konteks yang benar.

import 'package:flutter/material.dart';
import 'package:project_sicerdas/features/home/views/home_screen.dart';
// import 'package:project_sicerdas/features/chat/views/chat_screen.dart'; // Jika ada layar chat global
import 'package:project_sicerdas/features/profile/views/profile_screen.dart'; // Import ProfileScreen
import 'package:project_sicerdas/features/my_news/views/my_news_screen.dart'; // Import MyNewsScreen
import 'package:project_sicerdas/app/theme/app_colors.dart'; // Untuk warna icon
import 'package:provider/provider.dart'; // Import Provider
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart'; // Import AuthController
import 'package:project_sicerdas/features/my_news/controllers/my_news_controller.dart'; // Import MyNewsController

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index tab yang aktif

  // Daftar widget untuk setiap tab
  // Inisialisasi langsung di sini
  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const Text('Search Screen - Under Construction'), // Placeholder for Search
    const MyNewsScreen(), // Tab Berita Saya
    const ProfileScreen(), // Tab Profil
  ];

  @override
  void initState() {
    super.initState();
    // Tidak perlu lagi menginisialisasi _widgetOptions di sini
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Khusus untuk MyNewsScreen, panggil fetchMyNews saat tab-nya dipilih
      // untuk memastikan data selalu terbaru saat pengguna kembali ke tab ini.
      if (index == 2) {
        // Index 2 adalah MyNewsScreen
        // Pastikan MyNewsController sudah tersedia di context
        // Perbaikan: MyNewsController sudah disediakan di MultiProvider di main.dart,
        // sehingga langsung bisa diakses di sini.
        final myNewsController = Provider.of<MyNewsController>(context, listen: false);
        // Pastikan AuthController juga sudah tersedia dan diberikan ke MyNewsController
        final authController = Provider.of<AuthController>(context, listen: false);

        // Panggil setAuthController untuk memastikan MyNewsController memiliki referensi AuthController
        myNewsController.setAuthController(authController);
        myNewsController.fetchMyNews();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined), // Icon untuk Berita Saya
            activeIcon: Icon(Icons.newspaper),
            label: 'My News', // Label baru
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Icon untuk akun/profil
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary, // Warna icon yang aktif
        unselectedItemColor: AppColors.textGrey, // Warna icon yang tidak aktif
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Pastikan item tidak bergerak saat dipilih
        backgroundColor: AppColors.white, // Latar belakang navigation bar
      ),
    );
  }
}
