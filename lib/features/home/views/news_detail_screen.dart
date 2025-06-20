import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/features/chat/views/chat_screen.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildHeaderImage(), _buildContent(context)],
            ),
          ),
          _buildCustomAppBar(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(news: news), // Navigasi ke ChatScreen
            ),
          );
        },
        backgroundColor: AppColors.secondary,
        shape: const CircleBorder(), // Memastikan FAB berbentuk lingkaran
        child: Image.asset('assets/images/Bot.png', width: 30, height: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(), // Navigasi kembali
              tooltip: 'Kembali',
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {
                // Membangun teks untuk dibagikan
                String shareText = 'Baca berita ini: ${news.title}\n\n${news.content}';
                if (news.featuredImageUrl != null && news.featuredImageUrl!.isNotEmpty) {
                  shareText += '\n\nLihat gambar: ${news.featuredImageUrl!}';
                }
                Share.share(shareText, subject: 'Berita dari SICERDAS');
              },
              tooltip: 'Bagikan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Image.network(
        news.featuredImageUrl ?? '',
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
            ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        120,
      ), // Padding bawah untuk ruang FAB dan BottomAppBar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            news.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.lightGrey,
                child: Text(
                  'V',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Voi',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBlack),
                  ),
                  Text(
                    news.publishedDateFormatted,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  news.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            news.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.3),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    );
  }
}
