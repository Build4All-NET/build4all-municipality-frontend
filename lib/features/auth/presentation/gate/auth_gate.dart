// lib/features/auth/presentation/gate/auth_gate.dart
// ─────────────────────────────────────────
// Decides where to go on app start:
// - Has token → go to Home
// - No token  → go to Welcome
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../login/bloc/auth_bloc.dart';
import '../login/bloc/auth_state.dart';
import '../../data/services/auth_token_store.dart';
import '../../../welcome/presentation/screens/welcome_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final store = AuthTokenStore();
    final hasToken = await store.hasToken();
    if (!hasToken && mounted) {
      // No token → stay on welcome
    }
    // TODO: if has token → navigate to Home
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoggedIn) {
          // TODO: Navigate to Home screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful! Home screen coming soon.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: const WelcomeScreen(),
    );
  }
}
