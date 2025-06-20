import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/widgets/app_header.dart';
import 'package:project_sicerdas/app/widgets/news_card.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/features/home/controllers/news_controller.dart';
import 'package:project_sicerdas/features/home/views/news_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart';
import 'package:project_sicerdas/features/auth/views/auth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewsController(),
      child: Consumer<NewsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ); // Menampilkan loading
          }

          if (controller.errorMessage != null) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Gagal memuat berita.\n\nError: ${controller.errorMessage}',
                  ), // Menampilkan error
                ),
              ),
            );
          }

          return DefaultTabController(
            length: controller.categories.length,
            child: Scaffold(
              appBar: AppBar(
                title: const AppHeader(), // Menggunakan AppHeader sebagai judul
                bottom: TabBar(
                  isScrollable: true,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textGrey,
                  tabs: controller.categories.map((category) => Tab(text: category)).toList(),
                  onTap: (index) {
                    controller.selectCategory(
                      controller.categories[index],
                    ); // Update kategori terpilih
                  },
                ),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: AppSpacing.aPaddingMedium.copyWith(bottom: 0),
                    child: Consumer<AuthController>(
                      builder: (context, authController, _) {
                        final userName = authController.userModel?.displayName ?? 'Pengguna';
                        return Text(
                          'Selamat datang, $userName!', // Menampilkan sapaan personal
                          style: AppTypography.headlineSmall.copyWith(color: AppColors.textBlack),
                        );
                      },
                    ),
                  ),
                  AppSpacing.vsMedium,
                  Expanded(
                    child: TabBarView(
                      children:
                          controller.categories.map((category) {
                            final newsList =
                                (category == 'Semua')
                                    ? controller.filteredNews
                                    : controller.filteredNews
                                        .where((news) => news.category == category)
                                        .toList();

                            if (newsList.isEmpty) {
                              return Center(
                                child: Text(
                                  'Tidak ada berita di kategori "$category"',
                                ), // Menampilkan pesan jika kosong
                              );
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
                                        builder:
                                            (context) => NewsDetailScreen(
                                              news: news,
                                            ), // Navigasi ke detail berita
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: NewsCard(news: news), // Menampilkan kartu berita
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
      ),
    );
  }
}
