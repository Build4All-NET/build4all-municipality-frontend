import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/l10n/locale_cubit.dart';

class UserVerifyCodeScreen extends StatefulWidget {
  final String email;
  final String sharedReference;

  const UserVerifyCodeScreen({
    super.key,
    required this.email,
    required this.sharedReference,
  });

  @override
  State<UserVerifyCodeScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<UserVerifyCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _readStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('register_body');
    if (data != null) {
      final body = jsonDecode(data);
      print("Saved Body: $body");
    }
  }

  void _verify(AppLocalizations l10n) async {
    String code = _controllers.map((c) => c.text).join();

    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterFullCode)),
      );
      return;
    }

    final body = {
      "email": widget.email,
      "code": code,
      "sharedReference": widget.sharedReference,
    };

    print("VERIFY BODY: $body");
    await _readStoredData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.verifySuccess),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                Text(l10n.verifySubtitle),
                const SizedBox(height: 8),

                Text(widget.email,
                    style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // OTP fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
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
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _verify(l10n),
                    child: Text(l10n.verifyButton,
                        style: const TextStyle(fontSize: 16, color: Colors.white)),
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
