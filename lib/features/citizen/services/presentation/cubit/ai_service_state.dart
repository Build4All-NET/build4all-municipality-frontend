enum AiServiceStatus { initial, loading, success, error }

class AiServiceState {
  final AiServiceStatus status;
  final String? reply;
  final String? error;

  const AiServiceState({
    this.status = AiServiceStatus.initial,
    this.reply,
    this.error,
  });

  AiServiceState copyWith({
    AiServiceStatus? status,
    String? reply,
    String? error,
  }) {
    return AiServiceState(
      status: status ?? this.status,
      reply: reply ?? this.reply,
      error: error ?? this.error,
    );
  }
}
