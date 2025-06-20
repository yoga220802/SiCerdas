import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/widgets/app_header.dart'; // AppHeader untuk judul
import 'package:project_sicerdas/app/widgets/news_card.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/features/home/controllers/news_controller.dart';
import 'package:project_sicerdas/features/home/views/news_detail_screen.dart';
import 'package:provider/provider.dart';

// Import tema dan spacing
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart'; // AuthController untuk data pengguna
import 'package:project_sicerdas/features/auth/views/auth_screen.dart'; // AuthScreen untuk logout

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Memanggil fetchInitialNews setelah widget terpasang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsController = Provider.of<NewsController>(context, listen: false);
      newsController.fetchInitialNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.categories.isEmpty) {
          // Tampilkan loader jika data belum tersedia
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (controller.errorMessage != null) {
          // Tampilkan pesan error jika terjadi kesalahan
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Gagal memuat berita.\n\nError: ${controller.errorMessage}'),
              ),
            ),
          );
        }

        // Sinkronisasi TabBar dan TabBarView menggunakan DefaultTabController
        return DefaultTabController(
          length: controller.categories.length,
          child: Scaffold(
            appBar: AppBar(
              title: const AppHeader(), // Judul menggunakan AppHeader
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: AppColors.primary, // Warna indikator tab
                labelColor: AppColors.primary, // Warna teks tab terpilih
                unselectedLabelColor: AppColors.textGrey, // Warna teks tab tidak terpilih
                tabs: controller.categories.map((category) => Tab(text: category)).toList(),
                onTap: (index) {
                  // Update kategori terpilih saat tab diketuk
                  controller.selectCategory(controller.categories[index]);
                },
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sapaan personal pengguna
                Padding(
                  padding: AppSpacing.aPaddingMedium.copyWith(bottom: 0),
                  child: Consumer<AuthController>(
                    builder: (context, authController, _) {
                      final userName = authController.userModel?.displayName ?? 'Pengguna';
                      return Text(
                        'Selamat datang, $userName!',
                        style: AppTypography.headlineSmall.copyWith(color: AppColors.textBlack),
                      );
                    },
                  ),
                ),
                AppSpacing.vsMedium, // Spasi antara sapaan dan konten
                Expanded(
                  child: TabBarView(
                    children:
                        controller.categories.map((category) {
                          // Filter berita berdasarkan kategori
                          final newsList =
                              (category == 'Semua')
                                  ? controller.filteredNews
                                  : controller.filteredNews
                                      .where((news) => news.category == category)
                                      .toList();

                          if (newsList.isEmpty) {
                            return Center(child: Text('Tidak ada berita di kategori "$category"'));
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: newsList.length,
                            itemBuilder: (context, index) {
                              final news = newsList[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewsDetailScreen(news: news),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: NewsCard(news: news),
                                ),
                              );
                            },
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
