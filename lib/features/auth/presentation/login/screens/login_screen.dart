
import 'dart:convert';
import 'dart:ffi';

import 'package:baladiyati/core/auth/jwt_claims.dart';
import 'package:baladiyati/core/auth/jwt_reader.dart';
import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/auth/data/services/api_auth_build4all_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/features/auth/presentation/login/screens/reset_password_page.dart';
import 'package:baladiyati/features/auth/presentation/register/screens/user_register_screen.dart';
import 'package:baladiyati/features/citizen/home/presentation/screens/home_screen.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../../core/config/app_sizes.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../../../../../common/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool isCitizen = true;
  static int ownerProjectLinkId = int.parse(Env.ownerProjectLinkId);
  final _authapi = AuthApi(DioClient.build);
  final _muniapi = AuthApi(DioClient.municipalityDio);
  final _muni = AuthApi(DioClient.municipalityDio);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final String? data = prefs.getString('register_body');

    if (data == null) return null;

    return jsonDecode(data) as Map<String, dynamic>;
  }
  Future<void> printAllPrefs() async {
  final prefs = await SharedPreferences.getInstance();

  final keys = prefs.getKeys();

  for (final key in keys) {
    final value = prefs.get(key);
    print('$key : $value');
  }
}

  Future<void> _onLoginPressed(BuildContext context) async {
  if (!_formKey.currentState!.validate()) return;

  try {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    // ================================
    // 1. LOGIN
    // ================================
    final response = await _authapi.ownerLogin(
      email: email,
      password: password,
      ownerProjectLinkId: ownerProjectLinkId,
    );

    final String token = response.data['token'];

    if (token.isEmpty) throw Exception("Token is empty");

    await JwtStore.save(token);

    final claims = JwtClaims.decode(token);
    if (claims == null || claims['id'] == null) {
      throw Exception("Invalid token");
    }

    final int userId = int.parse(claims['id'].toString());

    print("User ID: $userId");

    // ================================
    // 2. NAVIGATE FIRST (IMPORTANT)
    // ================================
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );

    // ================================
    // 3. REGISTER IN BACKGROUND
    // ================================
    final prefs = await SharedPreferences.getInstance();
    final isRegistered = prefs.getBool("is_registered") ?? false;

    if (!isRegistered) {
      final prefsData = await _getFromPrefs();

      if (prefsData != null) {
        try {
          await _muniapi.register(
            email: email,
            password: password,
            fullName: prefsData['fullName'],
            phone: prefsData['phone'],
            role: prefsData['role'],
            municipalityId: prefsData['municipality_id'],
            ownerProjectLinkId: ownerProjectLinkId,
            build4allId: userId,
          );

          await prefs.setBool("is_registered", true);
          print("Municipality registration DONE");
        } catch (e) {
          print("Muni register failed: $e");
        }
      }
    }

  } catch (e) {
    print("Login error: $e");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Login failed"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = context.watch<ThemeCubit>().state;
    final colors = themeState.tokens.colors;
    final card = themeState.tokens.card;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3)),
              );
            }
            if (state.isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(l10n.successLogin),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2)),
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (_) => false,
                );
              });
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingLarge),
                    child: Container(
                      padding: EdgeInsets.all(card.padding),
                      decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(card.radius)),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Center(
                                child: Text(l10n.loginTitle,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold))),
                            const SizedBox(height: 8),
                            Center(
                                child: Text(l10n.loginSubtitle,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey))),
                            const SizedBox(height: 24),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(14)),
                              child: Row(children: [
                                _roleTab(
                                    context,
                                    l10n.employee,
                                    Icons.badge_outlined,
                                    !isCitizen,
                                    () => setState(() => isCitizen = false)),
                                _roleTab(
                                    context,
                                    l10n.citizen,
                                    Icons.person_outline,
                                    isCitizen,
                                    () => setState(() => isCitizen = true)),
                              ]),
                            ),
                            const SizedBox(height: 20),
                            Text(l10n.emailLabel),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration:
                                  InputDecoration(hintText: l10n.emailHint),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? l10n.fieldRequired
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(l10n.passwordLabel),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: l10n.passwordHint,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                  icon: Icon(_obscurePassword
                                      ? Icons.lock_outline
                                      : Icons.lock_open_outlined),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? l10n.fieldRequired
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ResetPasswordPage())),
                                child: Text(l10n.forgotPassword,
                                    style: TextStyle(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            PrimaryButton(
                              label: l10n.loginButton,
                              isLoading: state.isLoading,
                              onPressed: state.isLoading
                                  ? () {}
                                  : () => _onLoginPressed(context),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(l10n.noAccount),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const UserRegisterScreen())),
                                  child: Text(l10n.registerNow,
                                      style: TextStyle(
                                          color: colors.primary,
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                              TextDecoration.underline)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _roleTab(BuildContext context, String label, IconData icon,
      bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.black87),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
