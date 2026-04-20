import 'package:baladiyati/features/auth/data/models/auth_response_model.dart';
import 'package:dio/dio.dart';
// import '../models/login_request_dto.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  // Future<Response> login(LoginRequestDto body) {
  //   return _dio.post('/auth/admin/login', data: body.toJson());
  // }

  Future<Response<dynamic>> ownerSendOtp({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) {
    return _dio.post(
      '/auth/send-verification',
      data: {
        "email": email,
        "password": password,
        "ownerProjectLinkId": ownerProjectLinkId,
      },
      options: Options(
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );
  }
  Future<Response> refresh(String refreshToken) {
    return _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken.trim()},
    );
  }

  Future<Response> logout({required String refreshToken}) {
    return _dio.post(
      '/auth/logout',
      data: {'refreshToken': refreshToken.trim()},
    );
  }

  Future<Response> ownerVerifyOtp({
    required String email,
    required String code,
  }) {
    return _dio.post(
      '/auth/verify-email-code', // ✅ FIXED
      data: {
        'email': email,
        'code': code,
      },
       options: Options(
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );
  }
Future<Response<dynamic>> ownerCompleteProfile({
  required String pendingId,
  required String username,
  required String firstName,
  required String lastName,
  required bool isPublicProfile,
  required String ownerProjectLinkId,
}) {
  final formData = FormData.fromMap({
    'pendingId': pendingId,
    'username': username,
    'firstName': firstName,
    'lastName': lastName,
    'isPublicProfile': isPublicProfile.toString(), // 👈 important
    'ownerProjectLinkId': ownerProjectLinkId,
  });

  return _dio.post(
    '/auth/complete-profile',
    data: formData,
    options: Options(
      contentType: 'multipart/form-data',
    ),
  );
}

  Future<Response<dynamic>> ownerLogin({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) {
    return _dio.post(
      '/auth/user/login',
      data: {
        'email': email,
        'password': password,
        'ownerProjectLinkId': ownerProjectLinkId,
      },
    );
  }
  
     Future<Response<dynamic>> register({
  required String email,
  required String password,
  required String fullName,
  required String phone,
  required String role,
  required int municipalityId,
}) {
  return _dio.post(
    '/auth/users/register',
    data: {
      'email': email,
      'passwordHash': password,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'municipality': {
        'id': municipalityId,
      },
    },
    options: Options(
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );
} 
}