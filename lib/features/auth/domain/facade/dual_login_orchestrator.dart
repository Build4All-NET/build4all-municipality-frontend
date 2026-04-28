import 'package:baladiyati/features/auth/data/models/admin_login_response.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/api_auth_build4all_service.dart';

class DualLoginResult {
  final bool adminOk;
  final bool userOk;

  final AdminLoginResponse? admin;
  final String? userToken;
  final Map<String, dynamic>? userData;

  final String? error;

  const DualLoginResult({
    required this.adminOk,
    required this.userOk,
    this.admin,
    this.userToken,
    this.userData,
    this.error,
  });

  bool get both => adminOk && userOk;
  bool get none => !adminOk && !userOk;
}

class DualLoginOrchestrator {
  final AuthApi authApi;
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
    Map<String, dynamic>? userData;

    Object? adminError;
    Object? userError;

    // 1. Try admin login.
    try {
      final adminResponse = await authApi.adminLogin(
        usernameOrEmail: identifier,
        password: password,
        ownerProjectLinkId: ownerProjectLinkId,
      );

      final token = _stripBearer(adminResponse.token);

      if (token.isNotEmpty && adminResponse.role.trim().isNotEmpty) {
        admin = adminResponse;

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
      final token = (data['token'] ?? '').toString();

      if (token.isNotEmpty) {
        userToken = token;
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
      userData: userData,
    );
  }
}