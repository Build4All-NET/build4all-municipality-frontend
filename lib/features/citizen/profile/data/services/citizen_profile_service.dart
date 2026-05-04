import 'package:baladiyati/core/exceptions/app_exception.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class CitizenProfileService {
  final Dio _buildDio;
  final Dio _muniDio;

  CitizenProfileService({
    Dio? buildDio,
    Dio? muniDio,
  })  : _buildDio = buildDio ?? DioClient.build,
        _muniDio = muniDio ?? DioClient.muni;

  String _bearer(String token) {
    final clean = token.trim();

    if (clean.toLowerCase().startsWith('bearer ')) {
      return clean;
    }

    return 'Bearer $clean';
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

    return AppException(fallback, original: e);
  }

  // ==========================================================
  // GET FULL CITIZEN PROFILE
  // Build4All profile + Municipality profile
  // ==========================================================
  Future<CitizenProfileBundle> getCitizenProfile({
    required String token,
    required int build4allUserId,
  }) async {
    try {
      final headers = {
        'Authorization': _bearer(token),
      };

      final responses = await Future.wait([
        _buildDio.get(
          '/users/$build4allUserId',
          options: Options(headers: headers),
        ),
        _muniDio.get(
          '/users/profile',
          options: Options(headers: headers),
        ),
      ]);

      final coreResponse = responses[0];
      final municipalityResponse = responses[1];

      final coreData = Map<String, dynamic>.from(coreResponse.data as Map);
      final municipalityData =
          Map<String, dynamic>.from(municipalityResponse.data as Map);

      return CitizenProfileBundle(
        core: Build4AllCitizenProfile.fromJson(coreData),
        municipality: MunicipalityCitizenProfile.fromJson(municipalityData),
      );
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback: 'Failed to load citizen profile',
      );
    } catch (e) {
      throw AppException(
        'Failed to load citizen profile',
        original: e,
      );
    }
  }

  // ==========================================================
  // UPDATE BUILD4ALL CORE PROFILE
  // firstName / lastName / username / email / image
  // ==========================================================
  Future<Build4AllCitizenProfile> updateBuild4AllProfile({
    required String token,
    required int build4allUserId,
    required String firstName,
    required String lastName,
    String? username,
    String? email,
    bool? isPublicProfile,
    bool? imageRemoved,
    String? profileImagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        if (username != null && username.trim().isNotEmpty)
          'username': username.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (isPublicProfile != null)
          'isPublicProfile': isPublicProfile.toString(),
        if (imageRemoved != null) 'imageRemoved': imageRemoved.toString(),
        if (profileImagePath != null && profileImagePath.trim().isNotEmpty)
          'profileImage': await MultipartFile.fromFile(profileImagePath),
      });

      final response = await _buildDio.put(
        '/users/$build4allUserId/profile',
        data: formData,
        options: Options(
          headers: {
            'Authorization': _bearer(token),
          },
        ),
      );

      final data = Map<String, dynamic>.from(response.data as Map);

      final userData = data['user'] is Map
          ? Map<String, dynamic>.from(data['user'] as Map)
          : data;

      return Build4AllCitizenProfile.fromJson(userData);
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback: 'Failed to update Build4All profile',
      );
    } catch (e) {
      throw AppException(
        'Failed to update Build4All profile',
        original: e,
      );
    }
  }

  // ==========================================================
  // UPDATE MUNICIPALITY PROFILE
  // phone / address only
  // ==========================================================
  Future<MunicipalityCitizenProfile> updateMunicipalityProfile({
    required String token,
    String? phone,
    String? address,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (phone != null && phone.trim().isNotEmpty) {
        body['phone'] = phone.trim();
      }

      if (address != null && address.trim().isNotEmpty) {
        body['address'] = address.trim();
      }

      final response = await _muniDio.patch(
        '/users/profile',
        data: body,
        options: Options(
          headers: {
            'Authorization': _bearer(token),
          },
        ),
      );

      final data = Map<String, dynamic>.from(response.data as Map);

      return MunicipalityCitizenProfile.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(
        e,
        fallback: 'Failed to update municipality profile',
      );
    } catch (e) {
      throw AppException(
        'Failed to update municipality profile',
        original: e,
      );
    }
  }
}

// ==========================================================
// COMBINED PROFILE MODEL
// ==========================================================
class CitizenProfileBundle {
  final Build4AllCitizenProfile core;
  final MunicipalityCitizenProfile municipality;

  const CitizenProfileBundle({
    required this.core,
    required this.municipality,
  });

  String get fullName {
    final name = '${core.firstName} ${core.lastName}'.trim();

    if (name.isNotEmpty) return name;

    return core.username;
  }
}

// ==========================================================
// BUILD4ALL CORE PROFILE MODEL
// ==========================================================
class Build4AllCitizenProfile {
  final int id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final bool? isPublicProfile;
  final String? status;

  const Build4AllCitizenProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.profilePictureUrl,
    required this.isPublicProfile,
    required this.status,
  });

  factory Build4AllCitizenProfile.fromJson(Map<String, dynamic> json) {
    return Build4AllCitizenProfile(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      email: (json['email'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      profilePictureUrl: json['profilePictureUrl']?.toString() ??
          json['profileImageUrl']?.toString() ??
          json['avatarUrl']?.toString(),
      isPublicProfile: _readBool(json['isPublicProfile']),
      status: _readStatus(json['status']),
    );
  }
}

// ==========================================================
// MUNICIPALITY PROFILE MODEL
// ==========================================================
class MunicipalityCitizenProfile {
  final int id;
  final int? build4allId;
  final String email;
  final String phone;
  final String address;
  final String? status;
  final int? municipalityId;
  final String? municipalityName;
  final int? ownerProjectLinkId;

  const MunicipalityCitizenProfile({
    required this.id,
    required this.build4allId,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.municipalityId,
    required this.municipalityName,
    required this.ownerProjectLinkId,
  });

  factory MunicipalityCitizenProfile.fromJson(Map<String, dynamic> json) {
    return MunicipalityCitizenProfile(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      build4allId: int.tryParse(json['build4allId']?.toString() ?? ''),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      status: json['status']?.toString(),
      municipalityId: int.tryParse(json['municipalityId']?.toString() ?? ''),
      municipalityName: json['municipalityName']?.toString(),
      ownerProjectLinkId:
          int.tryParse(json['ownerProjectLinkId']?.toString() ?? ''),
    );
  }
}

// ==========================================================
// HELPERS
// ==========================================================
bool? _readBool(dynamic value) {
  if (value == null) return null;

  if (value is bool) return value;

  final text = value.toString().trim().toLowerCase();

  if (text == 'true') return true;
  if (text == 'false') return false;

  return null;
}

String? _readStatus(dynamic value) {
  if (value == null) return null;

  if (value is String) return value;

  if (value is Map) {
    return value['name']?.toString() ?? value['status']?.toString();
  }

  return value.toString();
}