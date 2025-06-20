import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_sicerdas/app/widgets/news_card.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/features/my_news/controllers/my_news_controller.dart';
import 'package:project_sicerdas/features/my_news/views/news_form_screen.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart';

class MyNewsScreen extends StatefulWidget {
  const MyNewsScreen({super.key});

  @override
  State<MyNewsScreen> createState() => _MyNewsScreenState();
}

class _MyNewsScreenState extends State<MyNewsScreen> {
  late MyNewsController _myNewsController;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _myNewsController = Provider.of<MyNewsController>(context, listen: false);
    _authController = Provider.of<AuthController>(context, listen: false);

    _myNewsController.setAuthController(_authController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _myNewsController.fetchMyNews();
    });
  }

  Future<void> _onRefresh() async {
    await _myNewsController.fetchMyNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Berita Saya',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textBlack),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Buat Berita Baru',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsFormScreen()),
              );
              if (result == true) {
                _onRefresh();
              }
            },
          ),
        ],
      ),
      body: Consumer<MyNewsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Padding(
                padding: AppSpacing.aPaddingMedium,
                child: Text(
                  'Gagal memuat berita Anda.\n\nError: ${controller.errorMessage}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (controller.myNews.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  AppSpacing.vsXXLarge,
                  Center(
                    child: Text(
                      'Anda belum memiliki berita. Buat yang pertama!',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textGrey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: ListView.builder(
              padding: AppSpacing.aPaddingMedium,
              itemCount: controller.myNews.length,
              itemBuilder: (context, index) {
                final news = controller.myNews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewsFormScreen(news: news)),
                      );
                      if (result == true) {
                        _onRefresh();
                      }
                    },
                    child: NewsCard(news: news),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
