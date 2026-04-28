// lib/features/auth/presentation/login/screens/login_screen.dart

import 'dart:convert';

import 'package:baladiyati/core/auth/jwt_claims.dart';
import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/auth/data/services/api_auth_build4all_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/features/forgotpassword/presentation/screens/reset_password_page.dart';
import 'package:baladiyati/features/auth/presentation/register/screens/user_register_screen.dart';
import 'package:baladiyati/features/citizen/home/presentation/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../../../../../core/config/app_sizes.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../../../../../common/widgets/primary_button.dart';
import '../../../../../common/widgets/app_toast.dart';
import '../../../../../common/widgets/app_text_field.dart';

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

  final _authApi = AuthApi(DioClient.build);
  final _municipalityAuthApi = AuthApi(DioClient.muni);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('register_body');
    if (data == null) return null;
    return jsonDecode(data);
  }

  Future<void> _onLoginPressed(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      final response = await _authApi.ownerLogin(
        email: email,
        password: password,
        ownerProjectLinkId: ownerProjectLinkId,
      );

      final token = response.data['token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception('Token is empty');
      }

      await JwtStore.save(token);

      final claims = JwtClaims.decode(token);
      if (claims == null || claims['id'] == null) {
        throw Exception('Invalid token');
      }

      final userId = int.parse(claims['id'].toString());

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );

      final prefs = await SharedPreferences.getInstance();
      final isRegistered = prefs.getBool('is_registered') ?? false;

      if (!isRegistered) {
        final prefsData = await _getFromPrefs();

        if (prefsData != null) {
          try {
            await _municipalityAuthApi.register(
              email: email,
              password: password,
              fullName: prefsData['fullName'],
              phone: prefsData['phone'],
              role: prefsData['role'],
              municipalityId: prefsData['municipality_id'],
              ownerProjectLinkId: ownerProjectLinkId,
              build4allId: userId,
            );

            await prefs.setBool('is_registered', true);
          } catch (_) {
            // Municipality registration is a secondary sync.
            // Login should not fail if this background registration fails.
          }
        }
      }
    } catch (_) {
      if (!mounted) return;

      AppToast.show(
        context,
        message: 'Login failed',
        type: AppToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final themeState = context.watch<ThemeCubit>().state;
    final colors = themeState.tokens.colors;
    final card = themeState.tokens.card;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              AppToast.show(
                context,
                message: state.errorMessage!,
                type: AppToastType.error,
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingLarge,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(card.padding),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(card.radius),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Center(
                              child: Text(
                                l10n.loginTitle,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Center(
                              child: Text(
                                l10n.loginSubtitle,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.outline,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Role switch.
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: cs.surfaceVariant,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  _roleTab(
                                    context,
                                    l10n.employee,
                                    Icons.badge_outlined,
                                    !isCitizen,
                                    () => setState(() => isCitizen = false),
                                  ),
                                  _roleTab(
                                    context,
                                    l10n.citizen,
                                    Icons.person_outline,
                                    isCitizen,
                                    () => setState(() => isCitizen = true),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            AppTextField(
                              controller: _emailCtrl,
                              label: l10n.emailLabel,
                              hint: l10n.emailHint,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textAlign: TextAlign.left,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return l10n.fieldRequired;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            AppTextField(
                              controller: _passwordCtrl,
                              label: l10n.passwordLabel,
                              hint: l10n.passwordHint,
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              textAlign: TextAlign.left,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: cs.primary,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return l10n.fieldRequired;
                                }
                                return null;
                              },
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ResetPasswordPage(),
                                  ),
                                ),
                                child: Text(
                                  l10n.forgotPassword,
                                  style: TextStyle(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            PrimaryButton(
                              label: l10n.loginButton,
                              isLoading: state.isLoading,
                              onPressed: () => _onLoginPressed(context),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.noAccount,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const UserRegisterScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.registerNow,
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
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

  Widget _roleTab(
    BuildContext context,
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? cs.primary : cs.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? cs.onPrimary : cs.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? cs.onPrimary : cs.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}