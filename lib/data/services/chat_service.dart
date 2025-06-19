import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatService {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  ChatService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception("GEMINI_API_KEY tidak ditemukan di .env");
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(maxOutputTokens: 2000),
    );

    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String text) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      final responseText = response.text;
      if (responseText == null) {
        return "Saya tidak mengerti, bisa coba lagi?";
      }
      return responseText;
    } catch (e) {
      print("Error sending message to Gemini: $e");
      return "Maaf, terjadi kesalahan. Coba lagi nanti.";
    }
  }
}
