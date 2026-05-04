// lib/features/citizen/services/data/services/request_service.dart

import 'package:baladiyati/core/network/api_client.dart';
import 'package:baladiyati/features/citizen/services/data/models/request_submission.dart';

class RequestService {
  final ApiClient _apiClient;

  RequestService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// POST /api/requests/{serviceId}
  /// serviceId = '2' for "شكوى أو مراجعة" (static)
  /// JWT token added automatically by ApiClient (requiresAuth: true)
  Future<void> submitRequest({
    required String serviceId,
    required RequestSubmission submission,
  }) async {
    await _apiClient.post(
      '/api/requests/$serviceId',
      body: submission.toJson(),
      requiresAuth: true,
    );
  }
}
