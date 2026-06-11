import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/exceptions/auth_exception.dart';
import 'package:baladiyati/features/auth/data/models/admin_login_response.dart';
import 'package:dio/dio.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Exception _handleError(DioException e, {String fallback = 'Request failed'}) {
    final data = e.response?.data;

    String? message;
    String? code;

    if (data is Map) {
      message = data['error'] ?? data['message'];
      code = data['code']?.toString();
    }

    final msg = (message ?? fallback).toString();

    if (code != null) {
      return AuthException(msg, code: code, original: e);
    }

    return AppException(msg, original: e);
  }

  Future<Response<dynamic>> ownerLogin({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    try {
      return await _dio.post(
        '/auth/user/login',
        data: {
          'email': email.trim(),
          'password': password.trim(),
          'ownerProjectLinkId': ownerProjectLinkId,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e, fallback: 'Login failed');
    } catch (e) {
      throw AppException('Login failed', original: e);
    }
  }

  Future<Response<dynamic>> ownerSendOtp({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    try {
      return await _dio.post(
        '/auth/send-verification',
        data: {
          'email': email.trim(),
          'password': password.trim(),
          'ownerProjectLinkId': ownerProjectLinkId,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e, fallback: 'Failed to send verification code');
    } catch (e) {
      throw AppException('Failed to send verification code', original: e);
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
          'email': email.trim(),
          'code': code.trim(),
        },
      );
    } on DioException catch (e) {
      throw _handleError(e, fallback: 'Failed to verify code');
    } catch (e) {
      throw AppException('Failed to verify code', original: e);
    }
  }

  Future<Response<dynamic>> ownerCompleteProfile({
    required String pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublicProfile,
    required String ownerProjectLinkId,
    String? email,
    String? profileImagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'pendingId': pendingId.trim(),
        'username': username.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'isPublicProfile': isPublicProfile.toString(),
        'ownerProjectLinkId': ownerProjectLinkId.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (profileImagePath != null && profileImagePath.trim().isNotEmpty)
          'profileImage': await MultipartFile.fromFile(profileImagePath),
      });

      return await _dio.post(
        '/auth/complete-profile',
        data: formData,
      );
    } on DioException catch (e) {
      throw _handleError(e, fallback: 'Failed to complete profile');
    } catch (e) {
      throw AppException('Failed to complete profile', original: e);
    }
  }

  Future<Response<dynamic>> refresh(String refreshToken) async {
    try {
      return await _dio.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken.trim(),
        },
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

  Future<Response<dynamic>> logout({
    required String refreshToken,
  }) async {
    try {
      return await _dio.post(
        '/auth/logout',
        data: {
          'refreshToken': refreshToken.trim(),
        },
      );
    } on DioException catch (e) {
      throw _handleError(e, fallback: 'Logout failed');
    } catch (e) {
      throw AppException('Logout failed', original: e);
    }
  }

  Future<AdminLoginResponse> adminLogin({
    required String usernameOrEmail,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/admin/login/front',
        data: {
          'usernameOrEmail': usernameOrEmail.trim(),
          'password': password.trim(),
          'ownerProjectId': ownerProjectLinkId,
        },
      );

      return AdminLoginResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw _handleError(e, fallback: 'Admin login failed');
    } catch (e) {
      throw AppException('Admin login failed', original: e);
    }
  }
}
