import 'package:equatable/equatable.dart';

enum AiChatStatus { initial, sending, error }

class AiChatMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const AiChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [text, isUser, timestamp];
}

class AiChatState extends Equatable {
  final List<AiChatMessage> messages;
  final AiChatStatus status;
  final int? conversationId;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.status = AiChatStatus.initial,
    this.conversationId,
    this.error,
  });

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    AiChatStatus? status,
    int? conversationId,
    String? error,
    bool clearError = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      conversationId: conversationId ?? this.conversationId,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [messages, status, conversationId, error];
}
