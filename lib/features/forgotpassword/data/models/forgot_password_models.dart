class ForgotMessageResponse {
  final String message;

  ForgotMessageResponse({required this.message});

  factory ForgotMessageResponse.fromJson(Map<String, dynamic> json) {
    final msg = (json['message'] ?? json['error'] ?? '').toString();
    return ForgotMessageResponse(message: msg.isEmpty ? 'OK' : msg);
  }
}
