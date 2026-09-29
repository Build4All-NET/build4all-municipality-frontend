import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/exceptions/auth_exception.dart';
import 'package:baladiyati/features/auth/data/models/admin_login_response.dart';
import 'package:dio/dio.dart';
import 'package:baladiyati/core/utils/picked_file.dart';
import 'package:baladiyati/core/l10n/app_strings.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Exception _handleError(DioException e, {String? fallback}) {
    fallback ??= AppStrings.current.errRequestFailed;
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
      throw _handleError(e, fallback: AppStrings.current.loginFailed);
    } catch (e) {
      throw AppException(AppStrings.current.loginFailed, original: e);
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
      throw _handleError(e, fallback: AppStrings.current.errSendCode);
    } catch (e) {
      throw AppException(AppStrings.current.errSendCode, original: e);
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
      throw _handleError(e, fallback: AppStrings.current.errVerifyCode);
    } catch (e) {
      throw AppException(AppStrings.current.errVerifyCode, original: e);
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
    PickedFileData? profileImage,
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
        if (profileImage != null) 'profileImage': profileImage.toDioMultipart(),
      });

      return await _dio.post(
        '/auth/complete-profile',
        data: formData,
      );
    } on DioException catch (e) {
      throw _handleError(e, fallback: AppStrings.current.errCompleteProfile);
    } catch (e) {
      throw AppException(AppStrings.current.errCompleteProfile, original: e);
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
        AppStrings.current.errSessionExpired,
        code: 'SESSION_EXPIRED',
        original: e,
      );
    } catch (e) {
      throw AppException(AppStrings.current.errSessionExpired, original: e);
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
      throw _handleError(e, fallback: AppStrings.current.errLogout);
    } catch (e) {
      throw AppException(AppStrings.current.errLogout, original: e);
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
      throw _handleError(e, fallback: AppStrings.current.loginFailed);
    } catch (e) {
      throw AppException(AppStrings.current.loginFailed, original: e);
    }
  }
}
