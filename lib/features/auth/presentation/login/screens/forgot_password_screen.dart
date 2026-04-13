// lib/features/auth/presentation/login/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/app/app_router.dart';
import '../../../../../features/auth/data/services/auth_api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String email;
  final String code; // ✅ received from VerifyResetCodeScreen

  const ForgotPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // ✅ Send email + code + new password to backend
      await AuthApiService().resetPassword(
        email: widget.email,
        newPassword: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.passwordUpdated),
          backgroundColor: Colors.green,
        ),
      );

      AppRouter.goToLogin(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = e.toString().replaceAll('Exception:', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFE3EAF2),
                  child: Icon(Icons.lock, size: 40, color: Color(0xFF0D1B2A)),
                ),
                const SizedBox(height: 20),
                Text(l10n.resetPasswordTitle,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(l10n.resetPasswordSubtitle,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center),
                const SizedBox(height: 30),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscure1,
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure1
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscure1 = !_obscure1),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.passwordRequired;
                    if (v.length < 6) return l10n.passwordTooShort;
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _obscure2,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure2
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscure2 = !_obscure2),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.passwordRequired;
                    if (v != passwordController.text)
                      return l10n.passwordNotMatch;
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B2A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading ? null : _onSave,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(l10n.savePassword,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white)),
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
