// lib/features/auth/domain/facade/dual_login_orchestrator.dart

import 'package:baladiyati/features/auth/data/models/admin_login_response.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/api_auth_build4all_service.dart';

class DualLoginResult {
  final bool adminOk;
  final bool userOk;

  final AdminLoginResponse? admin;

  final String? userToken;
  final String? userRefreshToken;
  final Map<String, dynamic>? userData;

  final String? error;

  const DualLoginResult({
    required this.adminOk,
    required this.userOk,
    this.admin,
    this.userToken,
    this.userRefreshToken,
    this.userData,
    this.error,
  });

  bool get both => adminOk && userOk;
  bool get none => !adminOk && !userOk;
}

class DualLoginOrchestrator {
  final AuthApi authApi;

  // Kept for compatibility with current constructor usage.
  // Do not save tokens here. Token persistence belongs to LoginScreen
  // after the final role choice is known.
  final AdminTokenStore adminStore;

  const DualLoginOrchestrator({
    required this.authApi,
    required this.adminStore,
  });

  String _stripBearer(String token) {
    final value = token.trim();

    if (value.toLowerCase().startsWith('bearer ')) {
      return value.substring(7).trim();
    }

    return value;
  }

  Future<DualLoginResult> login({
    required String identifier,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    AdminLoginResponse? admin;

    String? userToken;
    String? userRefreshToken;
    Map<String, dynamic>? userData;

    Object? adminError;
    Object? userError;

    // 1. Try admin/owner login.
    try {
      final adminResponse = await authApi.adminLogin(
        usernameOrEmail: identifier,
        password: password,
        ownerProjectLinkId: ownerProjectLinkId,
      );

      final cleanToken = _stripBearer(adminResponse.token);
      final cleanRole = adminResponse.role.trim();

      if (cleanToken.isNotEmpty && cleanRole.isNotEmpty) {
        admin = AdminLoginResponse(
          token: cleanToken,
          refreshToken: adminResponse.refreshToken.trim(),
          role: cleanRole,
          admin: adminResponse.admin,
          ownerProjectId: adminResponse.ownerProjectId,
        );
      }
    } catch (e) {
      adminError = e;
    }

    // 2. Try citizen/user login.
    try {
      final userResponse = await authApi.ownerLogin(
        email: identifier,
        password: password,
        ownerProjectLinkId: ownerProjectLinkId,
      );

      final data = Map<String, dynamic>.from(userResponse.data as Map);

      final token = (data['token'] ?? '').toString().trim();
      final refreshToken = (data['refreshToken'] ?? '').toString().trim();

      if (token.isNotEmpty) {
        userToken = _stripBearer(token);
        userRefreshToken = refreshToken.isEmpty ? null : refreshToken;
        userData = data;
      }
    } catch (e) {
      userError = e;
    }

    final adminOk = admin != null;
    final userOk = userToken != null && userToken!.isNotEmpty;

    if (!adminOk && !userOk) {
      return DualLoginResult(
        adminOk: false,
        userOk: false,
        error: userError?.toString() ??
            adminError?.toString() ??
            'Login failed',
      );
    }

    return DualLoginResult(
      adminOk: adminOk,
      userOk: userOk,
      admin: admin,
      userToken: userToken,
      userRefreshToken: userRefreshToken,
      userData: userData,
    );
  }
}