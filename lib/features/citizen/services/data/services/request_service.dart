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

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    final clean = token.trim();

    return clean.toLowerCase().startsWith('bearer ')
        ? clean
        : 'Bearer $clean';
  }

  Future<Options?> _authOptions() async {
    final token = await _bearerToken();

    if (token == null) {
      return null;
    }

    return Options(
      headers: {
        'Authorization': token,
      },
    );
  }

  /// GET /api/requests
  Future<List<RequestModel>> getMyRequests() async {
    try {
      final response = await _muniDio.get(
        '/api/requests',
        options: await _authOptions(),
      );

      final data = response.data;
      final List<dynamic> list = _extractList(data);

      return list
          .whereType<Map<String, dynamic>>()
          .map(RequestModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw _toAppException(
        error,
        fallback: 'Failed to load requests',
      );
    } catch (error) {
      throw AppException(error.toString());
    }
  }

  /// POST /api/requests/{serviceId}
  Future<void> submitRequest({
    required String serviceId,
    required RequestSubmission submission,
  }) async {
    try {
      await _muniDio.post(
        '/api/requests/$serviceId',
        data: submission.toJson(),
        options: await _authOptions(),
      );
    } on DioException catch (error) {
      throw _toAppException(
        error,
        fallback: 'Failed to submit request',
      );
    } catch (error) {
      throw AppException(error.toString());
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      if (data['data'] is List) return data['data'] as List;
      if (data['requests'] is List) return data['requests'] as List;
      if (data['items'] is List) return data['items'] as List;
      if (data['content'] is List) return data['content'] as List;
    }

    return [];
  }

  AppException _toAppException(
    DioException error, {
    required String fallback,
  }) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      return AppException(
        (data['message'] ?? data['error'] ?? fallback).toString(),
      );
    }

    if (data is String && data.trim().isNotEmpty) {
      return AppException(data);
    }

    return AppException(fallback);
  }
}