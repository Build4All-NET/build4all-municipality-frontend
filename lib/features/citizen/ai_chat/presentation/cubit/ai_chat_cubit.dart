import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/features/citizen/ai_chat/data/services/ai_chat_service.dart';
import 'ai_chat_state.dart';

class AiChatCubit extends Cubit<AiChatState> {
  AiChatCubit(this._service) : super(const AiChatState());

  final AiChatService _service;

  Future<void> sendMessage(String text, String language) async {
    if (text.trim().isEmpty) return;

    final userMsg = AiChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMsg],
      status: AiChatStatus.sending,
      clearError: true,
    ));

    try {
      final result = await _service.sendMessage(
        message: text.trim(),
        language: language,
        conversationId: state.conversationId,
      );

      final reply = (result['reply'] ?? result['message'] ?? '').toString();
      final convId = result['conversationId'] as int?;

      final aiMsg = AiChatMessage(
        text: _stripMarkdown(reply),
        isUser: false,
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(
        messages: [...state.messages, aiMsg],
        status: AiChatStatus.initial,
        conversationId: convId ?? state.conversationId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AiChatStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> clearConversation() async {
    final convId = state.conversationId;
    if (convId != null) {
      try {
        await _service.clearConversation(convId);
      } catch (_) {}
    }
    emit(const AiChatState());
  }

  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*{1,3}([^*]+)\*{1,3}'), r'$1')
        .replaceAll(RegExp(r'_{1,2}([^_]+)_{1,2}'), r'$1')
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
        .replaceAll(RegExp(r'^[-*+]\s+', multiLine: true), '• ')
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
        .trim();
  }
}
