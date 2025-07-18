import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/chat_message_model.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/features/chat/controllers/chat_controller.dart';
import 'package:project_sicerdas/app/theme/app_colors.dart';
import 'package:project_sicerdas/app/theme/app_typography.dart';
import 'package:project_sicerdas/app/theme/app_spacing.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final NewsModel news; // Objek berita sebagai konteks percakapan

  const ChatScreen({super.key, required this.news});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatController controller) {
    if (_textController.text.trim().isNotEmpty) {
      controller.sendMessage(_textController.text.trim()); // Mengirim pesan pengguna
      _textController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatController(news: widget.news),
      child: Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
            onPressed: () => Navigator.of(context).pop(), // Navigasi kembali
          ),
          title: Text(
            'Tanya AI',
            style: AppTypography.headlineSmall.copyWith(color: AppColors.textBlack),
          ),
          centerTitle: true,
        ),
        body: Consumer<ChatController>(
          builder: (context, controller, child) {
            _scrollToBottom();
            return Column(
              children: [
                _buildArticleHeader(context), // Header berita sebagai konteks
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: AppSpacing.aPaddingMedium,
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return _buildChatBubble(message, context); // Menampilkan chat bubble
                    },
                  ),
                ),
                if (controller.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: LinearProgressIndicator(color: AppColors.primary), // Indikator loading
                  ),
                _buildMessageInput(controller), // Input untuk pesan pengguna
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildArticleHeader(BuildContext context) {
    return Container(
      padding: AppSpacing.aPaddingMedium,
      margin: const EdgeInsets.all(16).copyWith(bottom: 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.news.featuredImageUrl ?? '',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: AppColors.backgroundGrey,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 30,
                      color: AppColors.textGrey,
                    ),
                  ),
            ),
          ),
          AppSpacing.hsMedium,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.news.title,
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary.withOpacity(0.2) : AppColors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
          ),
        ),
        child: Text(
          message.text,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textBlack),
        ),
      ),
    );
  }

  Widget _buildMessageInput(ChatController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(offset: Offset(0, -2), blurRadius: 5, color: Colors.black12)],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                style: AppTypography.bodyMedium,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan Anda...',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textGrey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.primary),
              onPressed: () => _sendMessage(controller),
            ),
          ],
        ),
      ),
    );
  }
}
