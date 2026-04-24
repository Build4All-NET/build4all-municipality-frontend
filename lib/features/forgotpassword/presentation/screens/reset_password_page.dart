// lib/features/auth/presentation/login/screens/reset_password_page.dart
// STEP 1: User enters email → backend sends OTP code to email

import 'package:flutter/material.dart';
import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/features/forgotpassword/data/services/forgot_password_api_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState
    extends State<ResetPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  static final int ownerProjectLinkId =
      int.parse(Env.ownerProjectLinkId);

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ForgotPasswordApiService()
          .sendResetCode(
        email: _emailCtrl.text.trim(),
        ownerProjectLinkId:
            ownerProjectLinkId,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      AppRouter
          .gotoVerifyResetCodeScreen(
        context,
        _emailCtrl.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      final msg = e
          .toString()
          .replaceAll('Exception:', '')
          .trim();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n =
        AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Center(
        child: Container(
          width: 350,
          padding:
              const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(
                  0.06,
                ),
                blurRadius: 16,
                offset:
                    const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment
                      .end,
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        Color(
                      0xFFE3EAF2,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 30,
                      color: Color(
                        0xFF0D1B2A,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 16),

                Center(
                  child: Text(
                    l10n
                        .resetPasswordTitle,
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 8),

                Center(
                  child: Text(
                    l10n
                        .resetPasswordSubtitle,
                    textAlign:
                        TextAlign
                            .center,
                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 20),

                Text(
                  l10n.emailLabel,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight
                            .bold,
                  ),
                ),

                const SizedBox(
                    height: 8),

                TextFormField(
                  controller:
                      _emailCtrl,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                  decoration:
                      InputDecoration(
                    hintText:
                        l10n.emailHint,
                    suffixIcon:
                        const Icon(
                      Icons
                          .email_outlined,
                    ),
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null ||
                        v
                            .trim()
                            .isEmpty) {
                      return l10n
                          .fieldRequired;
                    }

                    if (!v.contains(
                            '@') ||
                        !v.contains(
                            '.')) {
                      return l10n
                          .invalidEmail;
                    }

                    return null;
                  },
                ),

                const SizedBox(
                    height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child:
                      ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF0D1B2A,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    onPressed:
                        _isLoading
                            ? null
                            : _onSend,
                    child:
                        _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color: Colors
                                      .white,
                                ),
                              )
                            : Text(
                                l10n
                                    .sendCode,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      16,
                                  color: Colors
                                      .white,
                                ),
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}