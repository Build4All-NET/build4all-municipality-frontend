import 'dart:convert';

import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/build4all_profile_model.dart';
import '../models/municipality_profile_model.dart';

class ProfileApiService {
  final Dio _buildDio;
  final Dio _muniDio;
  final AuthTokenStore _userStore;

  ProfileApiService({
    Dio? buildDio,
    Dio? muniDio,
    AuthTokenStore? userStore,
  })  : _buildDio = buildDio ?? DioClient.build,
        _muniDio = muniDio ?? DioClient.muni,
        _userStore = userStore ?? AuthTokenStore();

  String _normalizeBearer(String token) {
    final clean = token.trim();

    if (clean.toLowerCase().startsWith('bearer ')) {
      return clean;
    }

    return 'Bearer $clean';
  }

  String _stripBearer(String token) {
    final clean = token.trim();

    if (clean.toLowerCase().startsWith('bearer ')) {
      return clean.substring(7).trim();
    }

    return clean;
  }

  Future<String> _token() async {
    final fromUserStore = await _userStore.getToken();

    if (fromUserStore != null && fromUserStore.trim().isNotEmpty) {
      return _normalizeBearer(fromUserStore);
    }

    final fromJwtStore = await JwtStore.getToken();

    if (fromJwtStore != null && fromJwtStore.trim().isNotEmpty) {
      return _normalizeBearer(fromJwtStore);
    }

    final prefs = await SharedPreferences.getInstance();

    final keys = [
      'token',
      'accessToken',
      'authToken',
      'auth_token',
      'userToken',
      'build4allToken',
    ];

    for (final key in keys) {
      final value = prefs.getString(key);

      if (value != null && value.trim().isNotEmpty) {
        return _normalizeBearer(value);
      }
    }

    throw AppException('Missing user auth token. Please login again.');
  }

  Future<int> _userId() async {
    final bearer = await _token();
    final rawJwt = _stripBearer(bearer);

    final idFromJwt = _extractUserIdFromJwt(rawJwt);
    if (idFromJwt > 0) return idFromJwt;

    final prefs = await SharedPreferences.getInstance();

    final keys = [
      'userId',
      'build4allUserId',
      'id',
      'currentUserId',
    ];

    for (final key in keys) {
      final intValue = prefs.getInt(key);
      if (intValue != null && intValue > 0) return intValue;

      final stringValue = prefs.getString(key);
      final parsed = int.tryParse(stringValue ?? '');

      if (parsed != null && parsed > 0) return parsed;
    }

    throw AppException('Missing user id. Please login again.');
  }

  int _extractUserIdFromJwt(String token) {
    try {
      final parts = token.split('.');

      if (parts.length != 3) return 0;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = Map<String, dynamic>.from(jsonDecode(decoded) as Map);

      final candidates = [
        json['id'],
        json['userId'],
        json['sub'],
      ];

      for (final value in candidates) {
        final parsed = int.tryParse(value?.toString() ?? '');
        if (parsed != null && parsed > 0) return parsed;
      }

      return 0;
    } catch (_) {
      return 0;
    }
  }

  Exception _handleError(
    DioException e, {
    String fallback = 'Request failed',
  }) {
    final data = e.response?.data;

    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? fallback;
      return AppException(message.toString(), original: e);
    }

    final status = e.response?.statusCode;

    if (status != null) {
      return AppException('$fallback. Error $status', original: e);
    }

    return AppException(fallback, original: e);
  }

  Future<Build4AllProfileModel> getBuild4AllProfile() async {
    try {
      final token = await _token();
      final userId = await _userId();

      if (kDebugMode) {
        debugPrint(
          '🟢 [PROFILE API] Build4All token exists = ${token.isNotEmpty}',
        );
        debugPrint(
          '🟢 [PROFILE API] token start = ${token.substring(0, token.length > 25 ? 25 : token.length)}...',
        );
        debugPrint('🟢 [PROFILE API] Build4All userId = $userId');
      }

      final response = await _buildDio.get(
        '/users/$userId',
        options: Options(
          headers: {
            'Authorization': token,
          },
        ),
      );

      return Build4AllProfileModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw _handleError(e, fallback: 'Failed to load Build4All profile');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to load Build4All profile', original: e);
    }
  }

  Future<MunicipalityProfileModel> getMunicipalityProfile() async {
    try {
      final token = await _token();

      if (kDebugMode) {
        debugPrint(
          '🟢 [PROFILE API] Municipality token exists = ${token.isNotEmpty}',
        );
      }

      final response = await _muniDio.get(
        '/users/profile',
        options: Options(
          headers: {
            'Authorization': token,
          },
        ),
      );

      return MunicipalityProfileModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw _handleError(e, fallback: 'Failed to load municipality profile');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to load municipality profile', original: e);
    }
  }

  Future<Build4AllProfileModel> updateBuild4AllProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? profileImagePath,
    bool imageRemoved = false,
  }) async {
    try {
      final token = await _token();
      final userId = await _userId();

      final formData = FormData.fromMap({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'username': username.trim(),
        if (email.trim().isNotEmpty) 'email': email.trim(),
        'imageRemoved': imageRemoved.toString(),
        if (profileImagePath != null && profileImagePath.trim().isNotEmpty)
          'profileImage': await MultipartFile.fromFile(profileImagePath),
      });

      final response = await _buildDio.put(
        '/users/$userId/profile',
        data: formData,
        options: Options(
          headers: {
            'Authorization': token,
          },
        ),
      );

      final data = Map<String, dynamic>.from(response.data as Map);

      final userJson = data['user'] is Map
          ? Map<String, dynamic>.from(data['user'] as Map)
          : data;

      return Build4AllProfileModel.fromJson(userJson);
    } on DioException catch (e) {
      throw _handleError(e, fallback: 'Failed to update Build4All profile');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to update Build4All profile', original: e);
    }
  }

  Future<MunicipalityProfileModel> updateMunicipalityProfile({
    required String phone,
    required String address,
  }) async {
    try {
      final token = await _token();
      final ownerProjectLinkId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

      if (ownerProjectLinkId <= 0) {
        throw AppException('Missing owner project link id.');
      }

      final response = await _muniDio.patch(
        '/users/profile',
        data: {
          'ownerProjectLinkId': ownerProjectLinkId,
          'phone': phone.trim(),
          'address': address.trim(),
        },
        options: Options(
          headers: {
            'Authorization': token,
            'Owner-Project-Link-Id': ownerProjectLinkId.toString(),
            'X-Owner-Project-Link-Id': ownerProjectLinkId.toString(),
          },
        ),
      );

      return MunicipalityProfileModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw _handleError(e, fallback: 'Failed to update municipality profile');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Failed to update municipality profile', original: e);
    }
  }
}