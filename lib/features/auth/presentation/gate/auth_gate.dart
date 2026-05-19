import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/core/network/auth_refresh_coordinator.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/Dashboard/presentation/screens/Dashboard_screen_admin.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:baladiyati/features/auth/data/services/session_role_store.dart';
import 'package:baladiyati/features/auth/presentation/municipality_profile/screens/municipality_profile_setup_screen.dart';
import 'package:baladiyati/features/citizen/home/presentation/screens/home_screen.dart';
import 'package:baladiyati/features/staff/dashboard/presentation/screens/staff_dashboard_screen.dart';
import 'package:baladiyati/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<Widget> _startScreenFuture;

  final AuthRefreshCoordinator _refreshCoordinator =
      AuthRefreshCoordinator.instance;

  @override
  void initState() {
    super.initState();
    _startScreenFuture = _resolveStartScreen();
  }

  Future<Widget> _resolveStartScreen() async {
    final adminStore = AdminTokenStore();
    final userStore = AuthTokenStore();
    final roleStore = SessionRoleStore();

    final tenantId = Env.ownerProjectLinkId;

    // 1. Owner/Admin session has priority.
    final adminTokenStored = await adminStore.getToken();

    if (adminTokenStored != null && adminTokenStored.trim().isNotEmpty) {
      final validAdminToken = await _refreshCoordinator.refreshAdminIfNeeded(
        tokenStored: adminTokenStored,
        tenantId: tenantId,
      );

      if (validAdminToken != null && validAdminToken.trim().isNotEmpty) {
        DioClient.setAuthToken(validAdminToken);
        await JwtStore.save(validAdminToken);

        return DashboardPage();
      }

      await adminStore.clear();
    }

    // 2. User session can be CITIZEN or STAFF.
    final userTokenStored = await userStore.getToken();
    final userWasInactive = await userStore.getWasInactive();

    if (userTokenStored != null && userTokenStored.trim().isNotEmpty) {
      final validUserToken = await _refreshCoordinator.refreshUserIfNeeded(
        tokenStored: userTokenStored,
        userWasInactive: userWasInactive,
        tenantId: tenantId,
      );

      if (validUserToken != null && validUserToken.trim().isNotEmpty) {
        DioClient.setAuthToken(validUserToken);
        await JwtStore.save(validUserToken);

        final role = await roleStore.getRole();

        if (role == 'STAFF') {
          return const StaffDashboardScreen();
        }

        return await _citizenRoute(validUserToken, userStore);
      }

      await userStore.clear();
      await JwtStore.clear();
      await roleStore.clearRole();
    }

    // 3. No valid session.
    DioClient.clearAuthToken();
    return const WelcomeScreen();
  }

  Future<Widget> _citizenRoute(String token, AuthTokenStore userStore) async {
    final ownerProjectLinkId = int.tryParse(Env.ownerProjectLinkId) ?? 0;
    final userJson = await userStore.getUserJson() ?? {};
    final userId = int.tryParse(userJson['id']?.toString() ?? '') ?? 0;

    if (ownerProjectLinkId <= 0 || userId <= 0) return const HomeScreen();

    final prefs = await SharedPreferences.getInstance();
    final key = 'municipality_profile_completed_${ownerProjectLinkId}_$userId';

    if (prefs.getBool(key) == true) return const HomeScreen();

    try {
      final response = await DioClient.muni.get('/users/profile');
      if (response.statusCode == 200) {
        await prefs.setBool(key, true);
        return const HomeScreen();
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      // 404 or 500 = no profile exists → show profile setup
      if (status == 404 || status == 500) {
        final email = userJson['email']?.toString()?.isNotEmpty == true
            ? userJson['email'].toString()
            : userJson['username']?.toString() ?? '';
        return MunicipalityProfileSetupScreen(
          build4allToken: token,
          ownerProjectLinkId: ownerProjectLinkId,
          build4allUser: userJson,
          fallbackEmail: email,
        );
      }
      // Any other network/server error → fail safe, go to HomeScreen
    } catch (_) {}

    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<Widget>(
      future: _startScreenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: cs.background,
            body: Center(
              child: CircularProgressIndicator(
                color: cs.primary,
              ),
            ),
          );
        }

        return snapshot.data ?? const WelcomeScreen();
      },
    );
  }
}