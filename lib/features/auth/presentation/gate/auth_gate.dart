// lib/features/auth/presentation/gate/auth_gate.dart

import 'package:baladiyati/features/admin/Dashboard/presentation/screens/Dashboard_screen_admin.dart';
import 'package:flutter/material.dart';

import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:baladiyati/features/citizen/home/presentation/screens/home_screen.dart';


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<Widget> _startScreenFuture;

  @override
  void initState() {
    super.initState();
    _startScreenFuture = _resolveStartScreen();
  }

  Future<Widget> _resolveStartScreen() async {
    final adminStore = AdminTokenStore();

    // 1. Admin has priority if admin token exists.
    final adminToken = await adminStore.getToken();
    if (adminToken != null && adminToken.trim().isNotEmpty) {
      return const DashboardPage();
    }

    // 2. Then check normal citizen/user token.
    final userToken = await JwtStore.getToken();
    if (userToken != null && userToken.trim().isNotEmpty) {
      return const HomeScreen();
    }

    // 3. No session found.
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