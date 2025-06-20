import 'package:flutter/material.dart';
import 'package:project_sicerdas/features/home/views/home_screen.dart';
import 'package:project_sicerdas/features/profile/views/profile_screen.dart';
import 'package:project_sicerdas/features/my_news/views/my_news_screen.dart';
import 'package:project_sicerdas/features/search/views/search_screen.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart';
import 'package:project_sicerdas/features/my_news/controllers/my_news_controller.dart';
import 'package:project_sicerdas/features/search/controllers/news_search_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar widget untuk setiap tab
  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const SearchScreen(),
    const MyNewsScreen(),
    const ProfileScreen(),
  ];

  late MyNewsController _myNewsController;
  late AuthController _authController;
  late NewsSearchController _newsSearchController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inisialisasi controller menggunakan Provider
    _myNewsController = Provider.of<MyNewsController>(context, listen: false);
    _authController = Provider.of<AuthController>(context, listen: false);
    _newsSearchController = Provider.of<NewsSearchController>(context, listen: false);

    _myNewsController.setAuthController(_authController);
  }

  // Mengatur aksi saat tab ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _myNewsController.fetchMyNews(); // Memuat berita pengguna
      }
      if (index == 1) {
        _newsSearchController.fetchTrendingNews(); // Memuat berita trending
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
            icon: Icon(Icons.newspaper_outlined),
            activeIcon: Icon(Icons.newspaper),
            label: 'My News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
      ),
    );
  }
}
