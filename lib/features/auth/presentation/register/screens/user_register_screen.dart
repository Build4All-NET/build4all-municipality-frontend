// lib/features/auth/presentation/register/screens/user_register_screen.dart

import 'dart:convert';

import 'package:baladiyati/common/registration_step_cubit.dart';
import 'package:baladiyati/common/registration_step_indicator.dart';
import 'package:baladiyati/common/widgets/app_text_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/features/auth/data/services/api_auth_build4all_service.dart';
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

  int get _ownerProjectLinkId => int.tryParse(Env.ownerProjectLinkId) ?? 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveToPrefs(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('register_body', jsonEncode(body));
  }

  Future<void> _onSubmit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final sharedReference = DateTime.now().millisecondsSinceEpoch.toString();

    final body = {
      'fullName': _nameCtrl.text.trim(),
      'email': email,
      'phone': _phoneCtrl.text.trim(),
      'sharedReference': sharedReference,
    };

    await _saveToPrefs(body);

    try {
      await _authApi.ownerSendOtp(
        email: email,
        password: password,
        ownerProjectLinkId: _ownerProjectLinkId,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);
      context.read<RegistrationStepCubit>().nextStep();

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
      if (!mounted) return;

      setState(() => _isLoading = false);

      final msg = e.toString().replaceAll('Exception:', '').trim();

      AppToast.show(
        context,
        message: msg,
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
                        child: Text(
                          l10n.registerTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      AppTextField(
                        controller: _nameCtrl,
                        label: l10n.fullNameLabel,
                        hint: l10n.fullNameHint,
                        icon: Icons.person_outline,
                        textAlign: TextAlign.right,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.fieldRequired;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

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
                          if (!v.contains('@') || !v.contains('.')) {
                            return l10n.invalidEmail;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        controller: _phoneCtrl,
                        label: l10n.phoneLabel,
                        hint: l10n.phoneHint,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.left,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l10n.fieldRequired;
                          }
                          if (!RegExp(r'^[0-9]{8}$').hasMatch(v.trim())) {
                            return l10n.eightDigits;
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
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
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
                          if (v.trim().length < 6) {
                            return l10n.passwordTooShort;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      PrimaryButton(
                        label: l10n.registerButton,
                        isLoading: _isLoading,
                        onPressed: () => _onSubmit(l10n),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.alreadyHaveAccount,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              l10n.loginNow,
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
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