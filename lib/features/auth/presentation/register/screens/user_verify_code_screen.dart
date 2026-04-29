// lib/features/auth/presentation/register/screens/user_verify_code_screen.dart

import 'dart:convert';

import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/common/registration_step_cubit.dart';
import 'package:baladiyati/common/registration_step_indicator.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/auth/data/services/api_auth_build4all_service.dart';
import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../features/auth/data/services/auth_api_service.dart';

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
  State<UserVerifyCodeScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<UserVerifyCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

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

  Future<void> _verify(AppLocalizations l10n) async {
    final code = _controllers.map((c) => c.text).join();

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

      final int? id = response.data['user']['id'];

      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString('register_body');

      Map<String, dynamic> body =
          existing != null ? jsonDecode(existing) : {};

      body = {
        ...body,
        'email': widget.email,
        'sharedReference': widget.sharedReference,
        'ownerProjectLinkId': widget.ownerProjectLinkId,
        'otpVerified': true,
        'userId': id,
      };

      await prefs.setString('register_body', jsonEncode(body));

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
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
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
                        onPressed: () => _verify(l10n),
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