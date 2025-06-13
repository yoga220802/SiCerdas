import 'package:flutter/material.dart';
import 'package:project_sicerdas/features/auth/controllers/auth_controller.dart';
import 'package:project_sicerdas/app/widgets/news_source.dart';
import 'package:provider/provider.dart';
import 'package:project_sicerdas/app/widgets/app_header.dart';
import 'package:project_sicerdas/app/widgets/news_card.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/features/home/controllers/news_controller.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = const [
    'General',
    'Business',
    'Entertainment',
    'Health',
    'Science',
    'Sports',
    'Technology',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsController = Provider.of<NewsController>(context, listen: false);
      if (newsController.articlesByCategory.isEmpty) {
        newsController.fetchInitialData(_categories.first);
      }
    });
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      final selectedCategory = _categories[_tabController.index];
      Provider.of<NewsController>(context, listen: false).fetchNewsForCategory(selectedCategory);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data user dari AuthController
    final authController = Provider.of<AuthController>(context);
    print('Debug: Current user -> ${authController.currentUser}');
    final username = authController.currentUser?.displayName ?? 'Pengguna';

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        backgroundColor: AppColors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(),
            AppSpacing.vsMedium,
            Padding(
              padding: const EdgeInsets.only(left: 4.0, top: 10),
              child: RichText(
                text: TextSpan(
                  style: AppTypography.headlineSmall.copyWith(color: AppColors.textGrey),
                  children: <TextSpan>[
                    const TextSpan(text: 'Selamat Datang,\n'),
                    TextSpan(
                      text: username,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3.0,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: AppTypography.bodyMedium.copyWith(fontWeight: AppTypography.bold),
          unselectedLabelStyle: AppTypography.bodyMedium,
          tabAlignment: TabAlignment.start,
          tabs: _categories.map((String category) => Tab(text: category)).toList(),
        ),
      ),
      body: Consumer<NewsController>(
        builder: (context, controller, child) {
          return TabBarView(
            controller: _tabController,
            children:
                _categories.map((String category) {
                  final lowerCaseCategory = category.toLowerCase();
                  return NewsCategoryView(
                    category: category,
                    news: controller.articlesByCategory[lowerCaseCategory] ?? [],
                    sources: controller.sourcesByCategory[lowerCaseCategory] ?? [],
                    isLoading: controller.isLoadingForCategory(lowerCaseCategory),
                    onRefresh: () => controller.fetchNewsForCategory(category),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}

class NewsCategoryView extends StatelessWidget {
  final String category;
  final List<NewsArticle> news;
  final List<ApiSource> sources;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const NewsCategoryView({
    super.key,
    required this.category,
    required this.news,
    required this.sources,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && news.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (!isLoading && news.isEmpty && sources.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.aPaddingLarge,
          child: Text(
            "Tidak ada berita atau sumber untuk kategori '$category'.",
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textGrey),
          ),
        ),
      );
    }

    final featuredNews = news.length > 5 ? news.take(5).toList() : news;
    final regularNews = news.length > 5 ? news.sublist(5) : <NewsArticle>[];

    void _goToDetail(NewsArticle article) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => NewsDetailScreen(article: article)),
      // );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.vsLarge,
            if (sources.isNotEmpty)
              NewsSourcesWidget(
                sources: sources,
                onSourceTap: (sourceId) {
                  print('Filter berdasarkan source: $sourceId');
                },
              ),
            if (featuredNews.isNotEmpty) ...[
              AppSpacing.vsLarge,
              _buildFeaturedSection(context, featuredNews, _goToDetail),
            ],
            if (regularNews.isNotEmpty) ...[
              AppSpacing.vsLarge,
              _buildRegularSection(context, regularNews, _goToDetail),
            ],
            AppSpacing.vsLarge,
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(
    BuildContext context,
    List<NewsArticle> articles,
    void Function(NewsArticle) onCardTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.hPaddingMedium,
          child: Text('Terbaru', style: AppTypography.headlineSmall),
        ),
        AppSpacing.vsMedium,
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.hPaddingMedium,
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.75,
                margin: const EdgeInsets.only(right: 16),
                child: FeaturedNewsCard(
                  article: articles[index],
                  onTap: () => onCardTap(articles[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRegularSection(
    BuildContext context,
    List<NewsArticle> articles,
    void Function(NewsArticle) onCardTap,
  ) {
    return Padding(
      padding: AppSpacing.hPaddingMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Berita diseluruh dunia', style: AppTypography.headlineSmall),
          AppSpacing.vsMedium,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            separatorBuilder: (context, index) => AppSpacing.vsMedium,
            itemBuilder: (context, index) {
              return RegularNewsCard(
                article: articles[index],
                onTap: () => onCardTap(articles[index]),
                onBookmarkTap: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}
