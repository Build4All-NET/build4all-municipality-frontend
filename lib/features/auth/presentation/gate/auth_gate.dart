// lib/features/auth/presentation/gate/auth_gate.dart

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
      // No token → stay on WelcomeScreen.
    }

    // TODO: If token exists, navigate to HomeScreen when auth flow is ready.
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Login successful! Home screen coming soon.'),
              backgroundColor: cs.primary,
            ),
          );
        }
      },
      child: const WelcomeScreen(),
    );
  }
}