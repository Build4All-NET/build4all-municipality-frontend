// lib/features/citizen/services/data/services/request_service.dart

import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:baladiyati/features/citizen/requests/data/models/request_model.dart';
import 'package:baladiyati/features/citizen/services/data/models/request_submission.dart';
import 'package:dio/dio.dart';

class RequestService {
  final Dio _muniDio;
  final AuthTokenStore _tokenStore;

  RequestService({
    Dio? muniDio,
    AuthTokenStore? tokenStore,
  })  : _muniDio = muniDio ?? DioClient.muni,
        _tokenStore = tokenStore ?? AuthTokenStore();

  Future<String?> _bearerToken() async {
    final token = await _tokenStore.getToken();
    if (token == null || token.trim().isEmpty) return null;
    final clean = token.trim();
    return clean.toLowerCase().startsWith('bearer ')
        ? clean
        : 'Bearer $clean';
  }

  /// GET /api/requests — fetch current user's requests from municipality server
  Future<List<RequestModel>> getMyRequests() async {
    try {
      final token = await _bearerToken();
      final response = await _muniDio.get(
        '/api/requests',
        options: token != null
            ? Options(headers: {'Authorization': token})
            : null,
      );

      final data = response.data;
      final List<dynamic> list;

      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else if (data is Map && data['requests'] is List) {
        list = data['requests'] as List;
      } else if (data is Map && data['items'] is List) {
        list = data['items'] as List;
      } else {
        list = [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map(RequestModel.fromJson)
          .toList();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        throw AppException(
          (data['message'] ?? data['error'] ?? 'Failed to load requests')
              .toString(),
        );
      }
      throw AppException('Failed to load requests');
    }
  }

  /// POST /api/requests/{serviceId} — uses DioClient.muni so OwnerInjector
  /// automatically adds Authorization and Owner-Project-Link-Id headers.
  Future<void> submitRequest({
    required String serviceId,
    required RequestSubmission submission,
  }) async {
    try {
      await _muniDio.post(
        '/api/requests/$serviceId',
        data: submission.toJson(),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        throw AppException(
          (data['message'] ?? data['error'] ?? 'Failed to submit request')
              .toString(),
        );
      }
      throw AppException('Failed to submit request');
    }
  }
}