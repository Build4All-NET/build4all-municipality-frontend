// lib/features/citizen/profile/data/services/profile_api_service.dart

import '../../../../../core/network/api_client.dart';
import '../models/profile_model.dart';

class ProfileApiService {
  final ApiClient _client;

  ProfileApiService({ApiClient? client})
      : _client = client ?? ApiClient();

  // ─────────────────────────────────────────────────
  // GET /users/profile
  // Header: Authorization: Bearer TOKEN  (requiresAuth: true)
  //         Owner-Project-Link-Id: ownerProjectLinkId
  // ─────────────────────────────────────────────────
  Future<ProfileModel> getProfile({
    required int ownerProjectLinkId,
  }) async {
    print('🔵 [PROFILE API] getProfile called');
    try {
      final data = await _client.get(
        '/users/profile',
        extraHeaders: {
          'Owner-Project-Link-Id': ownerProjectLinkId.toString(),
        },
      );
      print('🟢 [PROFILE API] getProfile SUCCESS: $data');
      return ProfileModel.fromJson(data);
    } catch (e) {
      print('🔴 [PROFILE API] getProfile ERROR: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────
  // PATCH /users/profile
  // Header: Authorization: Bearer TOKEN  (requiresAuth: true)
  //         Owner-Project-Link-Id: ownerProjectLinkId
  // Body: { ownerProjectLinkId, fullName, phone, address, username }
  // Only non-null fields are sent in the body
  // ─────────────────────────────────────────────────
  Future<ProfileModel> updateProfile({
    required int ownerProjectLinkId,
    String? fullName,
    String? phone,
    String? address,
    String? username,
  }) async {
    print('🔵 [PROFILE API] updateProfile called');
    try {
      final data = await _client.patch(
        '/users/profile',
        requiresAuth: true,
        body: {
          // Always send ownerProjectLinkId so the server knows which project
          'ownerProjectLinkId': ownerProjectLinkId,
          // Only include fields that were provided
          if (fullName != null) 'fullName': fullName,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
          if (username != null) 'username': username,
        },
        extraHeaders: {
          'Owner-Project-Link-Id': ownerProjectLinkId.toString(),
        },
      );
      print('🟢 [PROFILE API] updateProfile SUCCESS');
      return ProfileModel.fromJson(data);
    } catch (e) {
      print('🔴 [PROFILE API] updateProfile ERROR: $e');
      rethrow;
    }
  }
}