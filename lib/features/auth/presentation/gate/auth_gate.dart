import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/core/network/auth_refresh_coordinator.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/Dashboard/presentation/screens/Dashboard_screen_admin.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:baladiyati/features/auth/data/services/session_role_store.dart';
import 'package:baladiyati/features/citizen/home/presentation/screens/home_screen.dart';

import 'package:baladiyati/features/staff/dashboard/presentation/screens/staff_dashboard_screen.dart';
import 'package:baladiyati/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

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

        return const HomeScreen();
      }

      await userStore.clear();
      await JwtStore.clear();
      await roleStore.clearRole();
    }

    // 3. No valid session.
    DioClient.clearAuthToken();
    return const WelcomeScreen();
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