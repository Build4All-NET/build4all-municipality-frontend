// lib/features/auth/presentation/register/screens/user_verify_code_screen.dart

import 'dart:convert';

import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/common/registration_step_cubit.dart';
import 'package:baladiyati/common/registration_step_indicator.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/auth/data/services/api_auth_build4all_service.dart';
import 'package:baladiyati/features/auth/data/services/auth_api_service.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserVerifyCodeScreen extends StatefulWidget {
  final String email;
  final String sharedReference;
  final String password;
  final int ownerProjectLinkId;

  const UserVerifyCodeScreen({
    super.key,
    required this.email,
    required this.sharedReference,
    required this.password,
    required this.ownerProjectLinkId,
  });

  @override
  State<UserVerifyCodeScreen> createState() => _UserVerifyCodeScreenState();
}

class _UserVerifyCodeScreenState extends State<UserVerifyCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  final _authApi = AuthApi(DioClient.build);

  bool _isLoading = false;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  Future<void> _saveVerifiedUserToPrefs({required int userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString('register_body');

    final Map<String, dynamic> oldBody = existing != null
        ? Map<String, dynamic>.from(jsonDecode(existing) as Map)
        : <String, dynamic>{};

    final body = {
      ...oldBody,
      'email': widget.email,
      'sharedReference': widget.sharedReference,
      'ownerProjectLinkId': widget.ownerProjectLinkId,
      'otpVerified': true,
      'userId': userId,
      'pendingId': userId,
    };

    await prefs.setString('register_body', jsonEncode(body));
  }

  int _extractUserId(dynamic responseData) {
    if (responseData is Map) {
      final user = responseData['user'];
      if (user is Map && user['id'] != null) {
        return int.tryParse(user['id'].toString()) ?? 0;
      }
      if (responseData['id'] != null) {
        return int.tryParse(responseData['id'].toString()) ?? 0;
      }
      if (responseData['userId'] != null) {
        return int.tryParse(responseData['userId'].toString()) ?? 0;
      }
    }
    // userId not in response (e.g. "already verified" response) — use 0 as fallback
    return 0;
  }

  Future<void> _verify(AppLocalizations l10n) async {
    if (_isLoading) return;

    final code =
        _controllers.map((controller) => controller.text.trim()).join();

    if (code.length < 6) {
      AppToast.show(
        context,
        message: l10n.enterFullCode,
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authApi.ownerVerifyOtp(
        email: widget.email,
        code: code,
      );

      final userId = _extractUserId(response.data);
      await _saveVerifiedUserToPrefs(userId: userId);

      if (!mounted) return;

      setState(() => _isLoading = false);

      context.read<RegistrationStepCubit>().nextStep();

      AppToast.show(
        context,
        message: l10n.successRegister,
        type: AppToastType.success,
      );

      AppRouter.gotoCompleteProfile(context);
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

  void _handleOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
      return;
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Column(
          children: [
            const RegistrationStepIndicator(),
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: cs.onSurface.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: cs.primary.withOpacity(0.10),
                        child: Icon(
                          Icons.lock,
                          color: cs.primary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        l10n.verifyTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        l10n.verifySubtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.outline,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 45,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                keyboardType: TextInputType.number,
                                enabled: !_isLoading,
                                decoration: InputDecoration(
                                  counterText: '',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: cs.outline.withOpacity(0.35),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: cs.primary,
                                      width: 2,
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: cs.outline.withOpacity(0.20),
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  _handleOtpChanged(value, index);
                                },
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 25),

                      PrimaryButton(
                        label: l10n.verifyButton,
                        isLoading: _isLoading,
                        onPressed: () {
                          if (_isLoading) return;
                          _verify(l10n);
                        },
                      ),
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
