import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:provider/provider.dart';
import 'package:project_sicerdas/app/widgets/custom_text_field.dart';
import 'package:project_sicerdas/app/widgets/news_card.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/features/search/controllers/news_search_controller.dart';
import 'package:project_sicerdas/features/home/views/news_detail_screen.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late NewsSearchController _newsSearchController;

  static const String _placeholderImageUrl =
      'https://images.squarespace-cdn.com/content/v1/5bd2165c7788970aa9eb9c97/204b5aaa-ba03-4e74-b252-9edafeb8e8fb/Placeholder+%29.png';

  @override
  void initState() {
    super.initState();
    _newsSearchController = Provider.of<NewsSearchController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _newsSearchController.initializeController();
    });

    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        _newsSearchController.clearSearch();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cari',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.textBlack),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      body: Consumer<NewsSearchController>(
        builder: (context, controller, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: AppSpacing.aPaddingMedium,
                child: CustomTextField(
                  hintText: 'Cari berita...',
                  controller: _searchController,
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (query) {
                    controller.searchNews(query);
                  },
                ),
              ),
              Expanded(
                child:
                    controller.searchQuery.isEmpty
                        ? _buildTrendingTopicsSection(controller)
                        : _buildSearchResultsSection(controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrendingTopicsSection(NewsSearchController controller) {
    if (controller.isLoadingTrending) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessageTrending != null) {
      return Center(
        child: Padding(
          padding: AppSpacing.aPaddingMedium,
          child: Text(
            'Gagal memuat trending topik.\n\nError: ${controller.errorMessageTrending}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (controller.trendingNews.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada trending topik saat ini.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textGrey),
        ),
      );
    }

    final List<NewsModel> topNews =
        List.of(controller.trendingNews)
          ..sort((a, b) => b.viewCount.compareTo(a.viewCount))
          ..take(5).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.hPaddingMedium,
            child: Text('Trending Topik', style: AppTypography.headlineSmall),
          ),
          AppSpacing.vsMedium,
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                if (topNews.length > 0)
                  Positioned(
                    top: 80,
                    left: MediaQuery.of(context).size.width / 2 - (160 / 2),
                    child: _buildTrendingCircle(
                      news: topNews[0],
                      size: 160,
                      color: AppColors.primary,
                    ),
                  ),
                if (topNews.length > 1)
                  Positioned(
                    top: 20,
                    left: MediaQuery.of(context).size.width * 0.05,
                    child: _buildTrendingCircle(
                      news: topNews[1],
                      size: 100,
                      color: AppColors.error,
                    ),
                  ),
                if (topNews.length > 2)
                  Positioned(
                    top: 10,
                    right: MediaQuery.of(context).size.width * 0.05,
                    child: _buildTrendingCircle(
                      news: topNews[2],
                      size: 120,
                      color: AppColors.secondary,
                    ),
                  ),
                if (topNews.length > 3)
                  Positioned(
                    bottom: 10,
                    left: MediaQuery.of(context).size.width * 0.1,
                    child: _buildTrendingCircle(
                      news: topNews[3],
                      size: 90,
                      color: AppColors.textBlue,
                    ),
                  ),
                if (topNews.length > 4)
                  Positioned(
                    bottom: 0,
                    right: MediaQuery.of(context).size.width * 0.05,
                    child: _buildTrendingCircle(
                      news: topNews[4],
                      size: 80,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCircle({
    required NewsModel news,
    required double size,
    required Color color,
  }) {
    String formatViewCount(int count) {
      if (count >= 1000) {
        return '${NumberFormat.compact().format(count).replaceAll('K', ' ribu')} dilihat';
      }
      return '$count dilihat';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsDetailScreen(news: news)),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          image: DecorationImage(
            image:
                news.featuredImageUrl != null && news.featuredImageUrl!.isNotEmpty
                    ? NetworkImage(news.featuredImageUrl!)
                    : const NetworkImage(_placeholderImageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(size * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      news.title.split(' ')[0],
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textWhite,
                        fontSize: size * 0.15,
                        fontWeight: AppTypography.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vsTiny,
                    Text(
                      formatViewCount(news.viewCount),
                      style: AppTypography.overline.copyWith(
                        color: AppColors.textWhite.withOpacity(0.9),
                        fontSize: size * 0.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsSection(NewsSearchController controller) {
    if (controller.isLoadingSearch) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessageSearch != null) {
      return Center(
        child: Padding(
          padding: AppSpacing.aPaddingMedium,
          child: Text(
            'Gagal mencari berita.\n\nError: ${controller.errorMessageSearch}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (controller.searchResults.isEmpty && controller.searchQuery.isNotEmpty) {
      return Center(
        child: Text(
          'Tidak ada hasil untuk "${controller.searchQuery}"',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textGrey),
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.aPaddingMedium,
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final news = controller.searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewsDetailScreen(news: news)),
              );
            },
            child: NewsCard(news: news),
          ),
        );
      },
    );
  }
}
