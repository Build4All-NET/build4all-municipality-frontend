// lib/app/app_router.dart
import 'package:flutter/material.dart';
import '../features/welcome/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/login/screens/login_screen.dart';

class AppRouter {
  static void goToLogin(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  

  static void goToWelcome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }
}
