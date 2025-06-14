import 'package:flutter/material.dart';
import 'package:project_sicerdas/app/widgets/app_header.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsArticle article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(AppColors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                if (mounted) {
                  setState(() {
                    _progress = progress / 100;
                  });
                }
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onWebResourceError: (WebResourceError error) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
                print('Error loading page: ${error.description}');
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.article.url));
  }

  void _onChatbotTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka chatbot untuk: ${widget.article.url}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const AppHeader(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _onChatbotTap,
        backgroundColor: AppColors.secondary,
        shape: const CircleBorder(),
        tooltip: 'Mulai Chatbot',
        child: const Icon(Icons.support_agent_rounded, color: AppColors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.white,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomAction(
              icon: Icons.arrow_back,
              label: 'Kembali',
              onTap: () => Navigator.of(context).pop(),
            ),
            _buildBottomAction(icon: Icons.bookmark_border, label: 'Bookmark', onTap: () {}),
            _buildBottomAction(icon: Icons.share_outlined, label: 'Bagikan', onTap: () {}),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress,
              color: AppColors.primary,
              backgroundColor: AppColors.backgroundGrey,
            ),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textGrey, size: 24),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }
}
