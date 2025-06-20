import 'package:flutter/material.dart';
import 'package:project_sicerdas/data/models/chat_message_model.dart';
import 'package:project_sicerdas/data/models/news_model.dart';
import 'package:project_sicerdas/data/services/chat_service.dart';

class ChatController extends ChangeNotifier {
  final NewsModel news; // Objek berita yang diterima
  final ChatService _chatService = ChatService();

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ChatController({required this.news}) {
    _processInitialContent(); // Memproses konten awal saat controller dibuat
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Memberitahu UI tentang perubahan status loading
  }

  Future<void> _processInitialContent() async {
    _setLoading(true);

    const userMessageText = "Apa maksud berita ini?"; // Pesan awal dari pengguna
    _messages.add(
      ChatMessage(text: userMessageText, sender: MessageSender.user, timestamp: DateTime.now()),
    );
    notifyListeners();

    // Prompt untuk AI berdasarkan konten berita
    final promptForAI =
        "Apa maksud artikel dengan judul ${news.title} ini:\n\n---\n${news.content}\n---";

    final response = await _chatService.sendMessage(promptForAI); // Mengirim prompt ke AI

    _messages.add(
      ChatMessage(
        text: response,
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
      ), // Menambahkan respons AI
    );
    _setLoading(false);
  }

  Future<void> sendMessage(String text) async {
    _messages.add(
      ChatMessage(text: text, sender: MessageSender.user, timestamp: DateTime.now()),
    ); // Pesan pengguna
    _setLoading(true);

    final response = await _chatService.sendMessage(text); // Mengirim pesan ke AI

    _messages.add(
      ChatMessage(
        text: response,
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
      ), // Respons dari AI
    );
    _setLoading(false);
  }
}
