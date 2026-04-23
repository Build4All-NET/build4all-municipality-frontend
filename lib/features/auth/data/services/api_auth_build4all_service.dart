import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/exceptions/auth_exception.dart';
import 'package:dio/dio.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  // ==========================================================
  // ERROR HANDLER SIMPLE (IMPORTANT)
  // ==========================================================
  Exception _handleError(DioException e, {String fallback = 'Request failed'}) {
    final data = e.response?.data;

    String? message;
    String? code;

    if (data is Map) {
      message = data['error'] ?? data['message'];
      code = data['code'];
    }

    final msg = (message ?? fallback).toString();

    // 👉 si backend donne un code auth → AuthException
    if (code != null) {
      return AuthException(msg, code: code, original: e);
    }

    return AppException(msg, original: e);
  }

  // ==========================================================
  // LOGIN
  // ==========================================================
  Future<Response<dynamic>> ownerLogin({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    try {
      return await _dio.post(
        '/auth/user/login',
        data: {
          'email': email,
          'password': password,
          'ownerProjectLinkId': ownerProjectLinkId,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw AppException('Login failed', original: e);
    }
  }

  // ==========================================================
  // REGISTER
  // ==========================================================
  Future<Response<dynamic>> register({
  required String email,
  required String password,
  required String fullName,
  required String phone,
  required String role,
  required int municipalityId,
  required int ownerProjectLinkId,
  required int build4allId, 
}) async {
  try {
    return await _dio.post(
      '/auth/users/register',
      data: {
        'email': email,
        'passwordHash': password,
        'fullName': fullName,
        'phone': phone,
        'role': role,
        'ownerProjectLinkId': ownerProjectLinkId,
        'BuildForAllId': build4allId, // ✅ THIS is Build4All ID
        'municipality': {'id': municipalityId},
      },
    );
  } on DioException catch (e) {
    throw _handleError(e);
  } catch (e) {
    throw AppException('Registration failed', original: e);
  }
}
  // ==========================================================
  // OTP
  // ==========================================================
  Future<Response<dynamic>> ownerSendOtp({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    try {
      return await _dio.post(
        '/auth/send-verification',
        data: {
          "email": email,
          "password": password,
          "ownerProjectLinkId": ownerProjectLinkId,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw AppException('Failed to send OTP', original: e);
    }
  }

  Future<Response<dynamic>> ownerVerifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      return await _dio.post(
        '/auth/verify-email-code',
        data: {
          'email': email,
          'code': code,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw AppException('Failed to verify OTP', original: e);
    }
  }

  // ==========================================================
  // PROFILE
  // ==========================================================
  Future<Response<dynamic>> ownerCompleteProfile({
    required String pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublicProfile,
    required String ownerProjectLinkId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'pendingId': pendingId,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'isPublicProfile': isPublicProfile.toString(),
        'ownerProjectLinkId': ownerProjectLinkId,
      });

      return await _dio.post(
        '/auth/complete-profile',
        data: formData,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw AppException('Failed to complete profile', original: e);
    }
  }

  // ==========================================================
  // REFRESH
  // ==========================================================
  Future<Response<dynamic>> refresh(String refreshToken) async {
    try {
      return await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken.trim()},
      );
    } on DioException catch (e) {
      throw AuthException(
        'Session expired',
        code: 'SESSION_EXPIRED',
        original: e,
      );
    } catch (e) {
      throw AppException('Refresh failed', original: e);
    }
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================
  Future<Response<dynamic>> logout({
    required String refreshToken,
  }) async {
    try {
      return await _dio.post(
        '/auth/logout',
        data: {'refreshToken': refreshToken.trim()},
      );
    } on DioException catch (e) {
      throw AppException('Logout failed', original: e);
    } catch (e) {
      throw AppException('Logout failed', original: e);
    }
  }
}