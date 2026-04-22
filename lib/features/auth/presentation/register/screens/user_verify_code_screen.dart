// lib/features/auth/presentation/register/screens/user_verify_code_screen.dart

import 'dart:convert';

import 'package:baladiyati/common/registration_step_cubit.dart';
import 'package:baladiyati/common/registration_step_indicator.dart';
import 'package:baladiyati/core/auth/jwt_reader.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../features/auth/data/services/auth_api_service.dart';
import 'package:baladiyati/app/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/api_auth_build4all_service.dart';

class UserVerifyCodeScreen extends StatefulWidget {
  final String email;
  final String sharedReference;
  final String password; // ✅ in memory only, never stored on disk
  final int ownerProjectLinkId; // ✅ from build4all config

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
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _saveToPrefs(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('register_body', jsonEncode(body));
  }

  // ✅ Only reads non-sensitive data (fullName, email, phone) — no password
  Future<Map<String, dynamic>?> _readStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('register_body');
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

 void _verify(AppLocalizations l10n) async {
  final code = _controllers.map((c) => c.text).join();

  if (code.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.enterFullCode)),
    );
    return;
  }

  setState(() => _isLoading = true);

 print(widget.email + code);
  try {
    // ✅ STEP 1 — verify OTP
    final response = await _authApi.ownerVerifyOtp(
      email: widget.email,
      code: code,
    );

    final responseData = response.data;
    final int? id = responseData['user']['id'];

    // if (id == null) {
    //   throw Exception("ID not found in response");
    // }

    // ✅ STEP 2 — load existing register body
    final prefs = await SharedPreferences.getInstance();

    final String? existing = prefs.getString('register_body');

    Map<String, dynamic> body = existing != null
        ? jsonDecode(existing)
        : {};

    // ✅ STEP 3 — update EVERYTHING in ONE object
    body = {
      ...body,
      "email": widget.email,
      "sharedReference": widget.sharedReference,
      "ownerProjectLinkId": widget.ownerProjectLinkId,
      "otpVerified": true,
      "userId": id,
      "lastname": "joumaa"
    };
print("""
pendingId: ${body?["userId"]}
fullName: ${body?["fullName"]}
ownerProjectLinkId: ${body?["ownerProjectLinkId"]}
""");
    print(body['email']);
    await prefs.setString('register_body', jsonEncode(body));

    if (!mounted) return;

    setState(() => _isLoading = false);

    context.read<RegistrationStepCubit>().nextStep();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.successRegister),
        backgroundColor: Colors.green,
      ),
    );

    // ✅ STEP 5 — navigate
    AppRouter.gotoCompleteProfile(context);

  } catch (e) {
    setState(() => _isLoading = false);

    final errorMsg = e.toString().replaceAll('Exception:', '').trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: primary.withOpacity(0.1),
                        child: Icon(Icons.lock, color: primary),
                      ),
                      const SizedBox(height: 20),
                      Text(l10n.verifyTitle,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(l10n.verifySubtitle),
                      const SizedBox(height: 8),
                      Text(widget.email,
                          style: TextStyle(
                              color: primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      // OTP fields
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

          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,

          keyboardType: TextInputType.number,
          maxLength: 1,

          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },

          decoration: InputDecoration(
            counterText: "",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primary, width: 2),
            ),
          ),
        ),
      );
    }),
  ),
),
                      const SizedBox(height: 25),

                      // VERIFY BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isLoading ? null : () => _verify(l10n),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(l10n.verifyButton,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white)),
                        ),
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


