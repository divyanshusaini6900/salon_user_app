import 'dart:convert';

import 'package:http/http.dart' as http;

import 'openai_config.dart';

class OpenAIService {
  bool get isEnabled => OpenAIConfig.enableOpenAI && OpenAIConfig.apiKey.isNotEmpty;

  Future<String> reply(String userText) async {
    if (!isEnabled) {
      return 'OpenAI is disabled. Enable it in OpenAIConfig.';
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': OpenAIConfig.model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful salon concierge. Keep replies short, clear, and focused on booking help.',
          },
          {
            'role': 'user',
            'content': userText,
          },
        ],
        'temperature': 0.3,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = (data['choices'] as List).cast<Map<String, dynamic>>();
      if (choices.isEmpty) return 'I could not generate a response.';
      final message = choices.first['message'] as Map<String, dynamic>;
      return (message['content'] as String).trim();
    }

    return 'OpenAI error: ${response.statusCode}. Falling back to quick answers.';
  }
}
