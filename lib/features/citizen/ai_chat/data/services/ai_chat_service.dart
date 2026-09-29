import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:baladiyati/core/l10n/app_strings.dart';

class AiChatService {
  AiChatService({Dio? dio}) : _dio = dio ?? DioClient.muni;

  final Dio _dio;

  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String language,
    int? conversationId,
  }) async {
    final response = await _dio.post('/api/ai/chat', data: {
      'message': message,
      'language': language,
      if (conversationId != null) 'conversationId': conversationId,
    });
    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    throw Exception(AppStrings.current.errInvalidAiResponse);
  }

  Future<void> clearConversation(int conversationId) async {
    await _dio.delete(
      '/api/ai/conversation',
      queryParameters: {'conversationId': conversationId},
    );
  }
}
