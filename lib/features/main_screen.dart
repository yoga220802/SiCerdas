import 'package:flutter/material.dart';
import 'package:project_sicerdas/features/home/views/home_screen.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MainScreenView();
  }
}

class _MainScreenView extends StatefulWidget {
  const _MainScreenView();

  @override
  State<_MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<_MainScreenView> {
  int _selectedIndex = 0;

  // Daftar halaman/screen untuk setiap tab
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    // SearchScreen(),
    // BookmarkScreen(),
    // ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border_rounded),
            activeIcon: Icon(Icons.bookmark_rounded),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey.withValues(alpha: 0.8),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        elevation: 8.0,
      ),
    );
  }
}
