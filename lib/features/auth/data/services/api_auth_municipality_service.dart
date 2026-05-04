// lib/features/auth/data/services/api_auth_municipality_service.dart

import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/features/auth/data/models/auth_response_model.dart';
import 'package:dio/dio.dart';

class ApiAuthMunicipalityService {
  final Dio _dio;

  ApiAuthMunicipalityService(this._dio);

  AppException _handleDioError(
    DioException e, {
    String fallback = 'Municipality request failed',
  }) {
    final data = e.response?.data;

    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? fallback;
      final code = data['code']?.toString();

      return AppException(
        message.toString(),
        code: code,
        original: e,
      );
    }

    return AppException(
      fallback,
      original: e,
    );
  }

  Future<AuthResponseModel?> syncUserAfterBuild4AllLogin({
    required String build4allToken,
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required int municipalityId,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/users/register',
        options: Options(
          headers: {
            'Authorization': build4allToken.toLowerCase().startsWith('bearer ')
                ? build4allToken
                : 'Bearer $build4allToken',
          },
        ),
        data: {
          'email': email.trim(),
          'passwordHash': password,
          'fullName': fullName.trim(),
          'phone': phone.trim(),
          'role': 'USER',
          'municipality': {'id': municipalityId},
        },
      );

      if (response.data is Map) {
        return AuthResponseModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }

      return null;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      final message = data is Map
          ? (data['message'] ?? data['error'] ?? '').toString()
          : '';

      // If user already exists in Municipality DB, do not block login.
      if (status == 409 ||
          message.toLowerCase().contains('already') ||
          message.toLowerCase().contains('email already')) {
        return null;
      }

      throw _handleDioError(e, fallback: 'Failed to sync municipality user');
    } catch (e) {
      throw AppException('Failed to sync municipality user', original: e);
    }
  }
}