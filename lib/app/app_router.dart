// lib/app/app_router.dart
import 'package:baladiyati/features/auth/presentation/complete_profile/screens/complete_profile_screen.dart';
import 'package:baladiyati/features/auth/presentation/register/screens/user_register_screen.dart';
import 'package:baladiyati/features/auth/presentation/register/screens/user_verify_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/welcome/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/login/screens/login_screen.dart';

class AppRouter {
  static void goToLogin(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  static void goToWelcome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  static void gotoRegister(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const UserRegisterScreen()),
      (_) => false,
    );
  }

  static void gotoUserVerifyCodeScreen(
    BuildContext context, {
    required String email,
    required String sharedReference,
  }) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => UserVerifyCodeScreen(
          email: email,
          sharedReference: sharedReference,
        ),
      ),
      (_) => false,
    );
  }

  static void gotoCompleteProfile(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
      (_) => false,
    );
  }
}
