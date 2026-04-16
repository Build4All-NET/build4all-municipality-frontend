// lib/app/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/welcome/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/login/screens/login_screen.dart';
import '../features/auth/presentation/login/bloc/auth_bloc.dart';
import '../features/auth/presentation/register/screens/user_register_screen.dart';
import '../features/auth/presentation/register/screens/user_verify_code_screen.dart';
import '../features/auth/presentation/complete_profile/screens/complete_profile_screen.dart';
import '../features/auth/data/services/auth_api_service.dart';
import '../features/auth/presentation/login/screens/reset_password_page.dart';
import '../features/auth/presentation/login/screens/verify_reset_code_screen.dart';
import '../features/auth/presentation/login/screens/forgot_password_screen.dart';
// ✅ FIXED: Import correct HomeScreen (with BottomNav)
import '../features/citizen/home/presentation/screens/home_screen.dart';

class AppRouter {

  // ── Welcome ───────────────────────────────────────
  static void goToWelcome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  // ── Login ─────────────────────────────────────────
  static void goToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => AuthBloc(authApi: AuthApiService()),
          child: const LoginScreen(),
        ),
      ),
      (_) => false,
    );
  }

  // ── Register ──────────────────────────────────────
  static void gotoRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserRegisterScreen()),
    );
  }

  // ── Verify Code (Registration) ────────────────────
  static void gotoUserVerifyCodeScreen(
  BuildContext context, {
  required String email,
  required String sharedReference,
  required String password,
  required int ownerProjectLinkId,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => UserVerifyCodeScreen(
        email: email,
        sharedReference: sharedReference,
        password: password,
        ownerProjectLinkId: ownerProjectLinkId,
      ),
    ),
  );
}

  // ── Complete Profile ──────────────────────────────
  static void gotoCompleteProfile(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
      (_) => false,
    );
  }

  // ── STEP 1: Reset Password (enter email) ──────────
  static void gotoResetPasswordPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
    );
  }

  // ── STEP 2: Verify OTP code ───────────────────────
  static void gotoVerifyResetCodeScreen(BuildContext context, String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyResetCodeScreen(email: email),
      ),
    );
  }

  // ── STEP 3: Enter new password ────────────────────
  static void gotoForgotPasswordScreen(
    BuildContext context,
    String email, {
    String code = '',
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(email: email, code: code),
      ),
    );
  }

  // ── Home ──────────────────────────────────────────
  // ✅ FIXED: Now navigates to real HomeScreen with BottomNav
  static void gotoHomePage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }
}
