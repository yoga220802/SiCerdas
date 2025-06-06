import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/widgets/app_header.dart';
import 'package:project_sicerdas/app/widgets/category_tabs.dart';
import 'package:project_sicerdas/app/widgets/news_card.dart';
import 'package:project_sicerdas/app/widgets/news_source.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Semua';

  // --- DUMMY DATA --- (Ganti dengan data dari Controller/API)
  final List<NewsSource> _newsSources = [
    NewsSource(id: 'cnn', name: 'CNN Indonesia'),
    NewsSource(id: 'inews', name: 'iNews'),
    NewsSource(id: 'bbc-news', name: 'BBC News'),
    NewsSource(id: 'nbc-news', name: 'NBC News'),
    NewsSource(id: 'kompas', name: 'Kompas'),
  ];

  final List<NewsArticle> _featuredNews = [
    NewsArticle(
      id: 'feat1',
      title: 'Meta uji coba terbatas Meta AI di Whatsapp, Instagram, dan Messenger',
      url: '',
      urlToImage:
          'https://images.unsplash.com/photo-1633949319337-11c52a329975?q=80&w=1854&auto=format&fit=crop',
      publishedAt: DateTime(2025, 5, 24),
      source: const Source(id: 'inews', name: 'iNews'),
      category: 'Teknologi',
    ),
    NewsArticle(
      id: 'feat2',
      title: 'Elon Musk Pertimbangkan Larang Penggunaan iPhone di Perusahaannya',
      url: '',
      urlToImage:
          'https://images.unsplash.com/photo-1685374251726-35327bae38a5?q=80&w=2070&auto=format&fit=crop',
      publishedAt: DateTime(2025, 5, 23),
      source: const Source(id: 'bbc-news', name: 'BBC'),
      category: 'Teknologi',
    ),
  ];

  final List<NewsArticle> _regularNews = [
    NewsArticle(
      id: 'reg1',
      title: 'Pertama Dalam Sejarah AS, Ketua DPR Kevin McCarthy Dicopot Anggotanya',
      url: '',
      urlToImage:
          'https://images.unsplash.com/photo-1596954443477-96a014e75f8a?q=80&w=2070&auto=format&fit=crop',
      publishedAt: DateTime(2025, 5, 22),
      source: const Source(id: 'cnn', name: 'CNN Indonesia'),
      category: 'Politik',
      isBookmarked: true,
    ),
    NewsArticle(
      id: 'reg2',
      title: 'OpenAI Akhirnya Bocorkan GPT-5, Tapi Masih Minim Informasi',
      url: '',
      urlToImage:
          'https://images.unsplash.com/photo-1698844238328-3543f43b57a3?q=80&w=2070&auto=format&fit=crop',
      publishedAt: DateTime(2025, 5, 22),
      source: const Source(id: 'reuters', name: 'Voi'),
      category: 'Teknologi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppHeader(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryTabsWidget(),
            AppSpacing.vsLarge,

            NewsSourcesSection(),
            AppSpacing.vsLarge,

            FeaturedNewsSection(),
            AppSpacing.vsLarge,

            RegularNewsSection(),
            AppSpacing.vsLarge,
          ],
        ),
      ),
    );
  }
}

// Widget-widget di bawah ini bisa dipisah ke file sendiri jika makin kompleks

class CategoryTabsWidget extends StatefulWidget {
  const CategoryTabsWidget({super.key});

  @override
  State<CategoryTabsWidget> createState() => _CategoryTabsWidgetState();
}

class _CategoryTabsWidgetState extends State<CategoryTabsWidget> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = const ['Semua', 'Kesehatan', 'Politik', 'Olahraga', 'Teknologi'];

  @override
  Widget build(BuildContext context) {
    return CategoryTabs(
      selectedCategory: _selectedCategory,
      onCategoryChanged: (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
      categories: _categories,
    );
  }
}

class NewsSourcesSection extends StatelessWidget {
  const NewsSourcesSection({super.key});

  // DUMMY DATA
  static final List<NewsSource> _newsSources = [
    NewsSource(id: 'cnn', name: 'CNN'),
    NewsSource(id: 'inews', name: 'iNews'),
    NewsSource(id: 'bbc-news', name: 'BBC'),
    NewsSource(id: 'nbc-news', name: 'NBC'),
    NewsSource(id: 'kompas', name: 'Kompas'),
  ];

  @override
  Widget build(BuildContext context) {
    return NewsSourcesWidget(
      sources: _newsSources,
      onSourceTap: (sourceId) {
        print('Source tapped: $sourceId');
      },
    );
  }
}

class FeaturedNewsSection extends StatelessWidget {
  const FeaturedNewsSection({super.key});

  // DUMMY DATA
  static final List<NewsArticle> _featuredNews = [
    NewsArticle(
      id: 'feat1',
      title: 'Meta uji coba terbatas Meta AI di Whatsapp, Instagram, dan Messenger',
      url: '',
      urlToImage:
          'https://images.unsplash.com/photo-1633949319337-11c52a329975?q=80&w=1854&auto=format&fit=crop',
      publishedAt: DateTime(2025, 5, 24),
      source: const Source(id: 'inews', name: 'iNews'),
      category: 'Teknologi',
    ),
    NewsArticle(
      id: 'feat2',
      title: 'Elon Musk Pertimbangkan Larang Penggunaan iPhone di Perusahaannya',
      url: '',
      urlToImage:
          'https://images.unsplash.com/photo-1685374251726-35327bae38a5?q=80&w=2070&auto=format&fit=crop',
      publishedAt: DateTime(2025, 5, 23),
      source: const Source(id: 'bbc-news', name: 'BBC'),
      category: 'Teknologi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
            itemCount: _featuredNews.length,
            itemBuilder: (context, index) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.8, // 80% lebar layar
                margin: const EdgeInsets.only(right: 16),
                child: FeaturedNewsCard(article: _featuredNews[index], onTap: () {}),
              );
            },
          ),
        ),
      ],
    );
  }
}

class RegularNewsSection extends StatefulWidget {
  const RegularNewsSection({super.key});

  @override
  State<RegularNewsSection> createState() => _RegularNewsSectionState();
}

class _RegularNewsSectionState extends State<RegularNewsSection> {
  // DUMMY DATA
  final List<NewsArticle> _regularNews = [
    NewsArticle(
      id: 'reg1',
      title: 'Pertama Dalam Sejarah AS, Ketua DPR Kevin McCarthy Dicopot Anggotanya',
      url: '',
      urlToImage:
          'https://images.unsplash.com/photo-1596954443477-96a014e75f8a?q=80&w=2070&auto=format&fit=crop',
      publishedAt: DateTime(2025, 5, 22),
      source: const Source(id: 'cnn', name: 'CNN Indonesia'),
      category: 'Politik',
      isBookmarked: true,
    ),
    NewsArticle(
      id: 'reg2',
      title: 'OpenAI Akhirnya Bocorkan GPT-5, Tapi Masih Minim Informasi',
      url: '',
      urlToImage:
          'https://images.unsplash.com/photo-1698844238328-3543f43b57a3?q=80&w=2070&auto=format&fit=crop',
      publishedAt: DateTime(2025, 5, 22),
      source: const Source(id: 'reuters', name: 'Voi'),
      category: 'Teknologi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
            itemCount: _regularNews.length,
            separatorBuilder: (context, index) => AppSpacing.vsMedium,
            itemBuilder: (context, index) {
              return RegularNewsCard(
                article: _regularNews[index],
                onTap: () {},
                onBookmarkTap: () {
                  setState(() {
                    final currentArticle = _regularNews[index];
                    _regularNews[index] = currentArticle.copyWith(
                      isBookmarked: !currentArticle.isBookmarked,
                    );
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
