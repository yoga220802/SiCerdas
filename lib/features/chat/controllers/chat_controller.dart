import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/chat_message_model.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/data/services/chat_service.dart';

class ChatController extends ChangeNotifier {
  final NewsArticle article;
  final ChatService _chatService = ChatService();

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ChatController({required this.article}) {
    _summarizeArticle();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _summarizeArticle() async {
    _setLoading(true);
    final prompt =
        "Tolong ringkas berita dari URL ini dalam beberapa kalimat ringkas dan informatif tanpa mengurangi inti dari berita ini: ${article.url}";

    _messages.add(
      ChatMessage(
        text: "Tolong ringkas berita ini",
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();

    final response = await _chatService.sendMessage(prompt);

    _messages.add(
      ChatMessage(text: response, sender: MessageSender.bot, timestamp: DateTime.now()),
    );
    _setLoading(false);
  }

  Future<void> sendMessage(String text) async {
    _messages.add(ChatMessage(text: text, sender: MessageSender.user, timestamp: DateTime.now()));
    _setLoading(true);

    final response = await _chatService.sendMessage(text);

    _messages.add(
      ChatMessage(text: response, sender: MessageSender.bot, timestamp: DateTime.now()),
    );
    _setLoading(false);
  }
}
