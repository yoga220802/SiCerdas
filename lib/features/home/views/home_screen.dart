import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/widgets/app_header.dart'; // Import AppHeader kembali
import 'package:project_sicerdas/app/widgets/news_card.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/features/home/controllers/news_controller.dart';
import 'package:project_sicerdas/features/home/views/news_detail_screen.dart';
import 'package:provider/provider.dart';

// Import tema dan spacing
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart'; // Perbaikan: import app_spacing.dart
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart'; // Import AuthController
import 'package:project_sicerdas/features/auth/views/auth_screen.dart'; // Import AuthScreen untuk logout

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NewsController _newsController; // Deklarasikan di sini

  @override
  void initState() {
    super.initState();
    // Memanggil fetchInitialNews setelah widget terpasang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _newsController = Provider.of<NewsController>(context, listen: false); // Inisialisasi
      _newsController.fetchInitialNews();
    });
  }

  // Metode untuk melakukan refresh data
  Future<void> _onRefresh() async {
    await _newsController.fetchInitialNews();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.categories.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (controller.errorMessage != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Gagal memuat berita.\n\nError: ${controller.errorMessage}'),
              ),
            ),
          );
        }

        // Gunakan DefaultTabController untuk sinkronisasi TabBar dan TabBarView
        return DefaultTabController(
          length: controller.categories.length,
          child: Scaffold(
            appBar: AppBar(
              // Menggunakan AppHeader sebagai judul
              title: const AppHeader(),
              // Letakkan TabBar di bagian bawah AppBar
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: AppColors.primary, // Warna indikator tab
                labelColor: AppColors.primary, // Warna teks tab terpilih
                unselectedLabelColor: AppColors.textGrey, // Warna teks tab tidak terpilih
                tabs: controller.categories.map((category) => Tab(text: category)).toList(),
                onTap: (index) {
                  // Update kategori terpilih di controller saat tab diketuk
                  controller.selectCategory(controller.categories[index]);
                },
              ),
            ),
            // Body menggunakan Column untuk menempatkan greeting, spasi, dan TabBarView
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian Greeting "Selamat datang, [Nama Pengguna]!"
                Padding(
                  padding: AppSpacing.aPaddingMedium.copyWith(bottom: 0), // Atur padding
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
                AppSpacing.vsMedium, // Spasi antara greeting dan konten di bawahnya
                Expanded(
                  child: TabBarView(
                    children:
                        controller.categories.map((category) {
                          // Dapatkan berita yang sudah difilter untuk setiap kategori
                          final newsList =
                              (category == 'Semua')
                                  ? controller.filteredNews
                                  : controller.filteredNews
                                      .where((news) => news.category == category)
                                      .toList();

                          // Wrap konten setiap tab dengan RefreshIndicator
                          return RefreshIndicator(
                            onRefresh: _onRefresh, // Panggil metode refresh
                            color: AppColors.primary, // Warna indikator refresh
                            child:
                                newsList.isEmpty
                                    ? ListView(
                                      // Wrap dengan ListView agar RefreshIndicator bisa bekerja meskipun konten kosong
                                      physics:
                                          const AlwaysScrollableScrollPhysics(), // Selalu bisa digulir
                                      children: [
                                        AppSpacing.vsXXLarge, // Beri jarak dari atas
                                        Text(
                                          'Tidak ada berita di kategori "$category"',
                                          textAlign: TextAlign.center,
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                      ],
                                    )
                                    : ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(), // Pastikan selalu bisa digulir
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
                                    ),
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
