import 'package:flutter/material.dart';
import 'package:project_sicerdas/features/home/views/home_screen.dart';
import 'package:project_sicerdas/features/chat/views/chat_screen.dart';
import 'package:project_sicerdas/features/profile/views/profile_screen.dart'; // Import ProfileScreen
import 'package:project_sicerdas/app/theme/app_colors.dart'; // Untuk warna icon

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index tab yang aktif

  // Daftar widget untuk setiap tab
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    // Contoh: ChatScreen(news: someDefaultNews), // Jika Anda ingin layar chat di tab terpisah
    Text('Search Screen - Under Construction'), // Placeholder for Search
    Text('Bookmark Screen - Under Construction'), // Placeholder for Bookmark
    ProfileScreen(), // Menambahkan ProfileScreen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
            icon: Icon(Icons.bookmark_border_outlined),
            activeIcon: Icon(Icons.bookmark),
            label: 'Bookmark',
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
