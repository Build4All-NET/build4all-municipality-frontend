// lib/features/auth/presentation/register/screens/user_register_screen.dart

import 'dart:convert';

import 'package:baladiyati/common/registration_step_cubit.dart';
import 'package:baladiyati/common/registration_step_indicator.dart';
import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/features/auth/data/services/api_auth_build4all_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baladiyati/features/auth/presentation/register/screens/user_verify_code_screen.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../../../../../common/widgets/primary_button.dart';
import '../../../../../features/auth/data/services/auth_api_service.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authApi = AuthApi(DioClient.build);
  bool _obscurePassword = true;
  bool _isLoading = false;

  // ✅ ownerProjectLinkId from build4all config
 int get _ownerProjectLinkId {
  return int.tryParse(Env.ownerProjectLinkId) ?? 0;
}

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ✅ Save only non-sensitive data (no password)
  Future<void> _saveToPrefs(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('register_body', jsonEncode(body));
  }

  void _onSubmit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim(); // stays in memory only
    final sharedReference = DateTime.now().millisecondsSinceEpoch.toString();

    // ✅ Save non-sensitive data only — no password
    final body = {
      "fullName": _nameCtrl.text.trim(),
      "email": email,
      "phone": _phoneCtrl.text.trim(),
      "sharedReference": sharedReference,
    };
    await _saveToPrefs(body);
    print("BASE URL: ${DioClient.build.options.baseUrl}");
    print("EMAIL: $email");
    print("PASSWORD: $password");
    try {
      // ✅ STEP 1 — Call build4all API (ownerProjectLinkId required)
      await _authApi.ownerSendOtp(
        email: email,
        password: password,
        ownerProjectLinkId: _ownerProjectLinkId,
      );

      setState(() => _isLoading = false);
      context.read<RegistrationStepCubit>().nextStep();

      // ✅ STEP 3 — Navigate to OTP, password passed in memory
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserVerifyCodeScreen(
            email: email,
            sharedReference: sharedReference,
            password: password,
            ownerProjectLinkId: _ownerProjectLinkId,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception:', '').trim();
      print(msg);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = context.watch<ThemeCubit>().state;
    final colors = themeState.tokens.colors;
    final card = themeState.tokens.card;
    final darkBlue = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            const RegistrationStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(card.padding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Text(l10n.registerTitle,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: darkBlue)),
                      ),
                      const SizedBox(height: 20),

                      // FULL NAME
                      Text(l10n.fullNameLabel,
                          style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          hintText: l10n.fullNameHint,
                          filled: true,
                          fillColor: colors.surface,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(card.radius)),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                      ),
                      const SizedBox(height: 16),

                      // EMAIL
                      Text(l10n.emailLabel,
                          style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: l10n.emailHint,
                          filled: true,
                          fillColor: colors.surface,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(card.radius)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                          if (!v.contains('@') || !v.contains('.'))
                            return l10n.invalidEmail;
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // PHONE
                      Text(l10n.phoneLabel,
                          style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: l10n.phoneHint,
                          filled: true,
                          fillColor: colors.surface,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(card.radius)),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                          if (!RegExp(r'^[0-9]{8}$').hasMatch(v.trim()))
                            return l10n.eightDigits;
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // PASSWORD
                      Text(l10n.passwordLabel,
                          style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: l10n.passwordHint,
                          filled: true,
                          fillColor: colors.surface,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(card.radius)),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(_obscurePassword
                                ? Icons.lock_outline
                                : Icons.lock_open_outlined),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                          if (v.trim().length < 6) return l10n.passwordTooShort;
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // REGISTER BUTTON
                      PrimaryButton(
                        label: l10n.registerButton,
                        isLoading: _isLoading,
                        onPressed: () => _onSubmit(l10n),
                      ),
                      const SizedBox(height: 16),

                      // LOGIN LINK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.alreadyHaveAccount),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(l10n.loginNow,
                                style: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
