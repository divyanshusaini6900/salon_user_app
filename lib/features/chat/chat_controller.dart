import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'openai_service.dart';

class ChatMessage {
  ChatMessage({required this.text, required this.isUser, required this.timestamp});

  final String text;
  final bool isUser;
  final DateTime timestamp;
}

class ChatController extends StateNotifier<List<ChatMessage>> {
  ChatController(this._ref)
      : super([ChatMessage(text: 'Hi! How can I help you today?', isUser: false, timestamp: DateTime.now())]);

  final Ref _ref;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    state = [...state, ChatMessage(text: trimmed, isUser: true, timestamp: DateTime.now())];

    final openAI = _ref.read(openAIServiceProvider);
    if (openAI.isEnabled) {
      state = [...state, ChatMessage(text: 'Typing...', isUser: false, timestamp: DateTime.now())];
      final reply = await openAI.reply(trimmed);
      _replaceLast(reply);
      return;
    }

    final reply = _replyFor(trimmed);
    state = [...state, ChatMessage(text: reply, isUser: false, timestamp: DateTime.now())];
  }

  void _replaceLast(String reply) {
    if (state.isEmpty) return;
    final updated = [...state]..removeLast();
    state = [...updated, ChatMessage(text: reply, isUser: false, timestamp: DateTime.now())];
  }

  String _replyFor(String input) {
    final normalized = input.toLowerCase();
    if (normalized.contains('price') || normalized.contains('cost')) {
      return 'Our services start at ?699. Signature Haircut is ?799 and Luxe Color Blend is ?2199.';
    }
    if (normalized.contains('time') || normalized.contains('open') || normalized.contains('timing')) {
      return 'We are open 9:00 AM to 8:00 PM, Monday to Sunday.';
    }
    if (normalized.contains('status') || normalized.contains('booking')) {
      return 'Your booking is confirmed once you reach the summary screen and tap ?Confirm booking?.';
    }
    if (normalized.contains('cancel')) {
      return 'You can cancel up to 6 hours before your slot. A full refund is processed within 24 hours.';
    }
    if (normalized.contains('recommend') || normalized.contains('style')) {
      return 'Try the AI Style Studio tab for personalized hairstyle suggestions.';
    }
    return 'Got it! I can help with pricing, timings, bookings, and cancellation policy.';
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
  return ChatController(ref);
});

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});
