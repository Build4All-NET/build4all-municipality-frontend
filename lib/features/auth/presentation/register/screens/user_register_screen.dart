import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:baladiyati/features/auth/presentation/register/screens/user_verify_code_screen.dart';

import '../../../../../core/l10n/locale_cubit.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../../../../../common/widgets/primary_button.dart';

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

  bool _obscurePassword = true;

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

  void _onSubmit(bool ar, bool fr) async {
    if (!_formKey.currentState!.validate()) return;

    final sharedReference =
        DateTime.now().millisecondsSinceEpoch.toString();

    final body = {
      "fullName": _nameCtrl.text.trim(),
      "email": _emailCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
      "password": _passwordCtrl.text.trim(),
      "sharedReference": sharedReference,
    };

    await _saveToPrefs(body);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserVerifyCodeScreen(
          email: _emailCtrl.text.trim(),
          sharedReference: sharedReference,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();
    final themeState = context.watch<ThemeCubit>().state;

    final colors = themeState.tokens.colors;
    final card = themeState.tokens.card;

    final ar = localeCubit.isArabic;
    final fr = localeCubit.isFrench;

    // 🔵 Dark Blue Color
    final darkBlue = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(card.padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 20),

                // TITLE
                Center(
                  child: Text(
                    ar ? 'إنشاء حساب' : fr ? 'Créer un compte' : 'Sign Up',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // NAME
                Text(
                  ar ? 'الاسم الكامل' : fr ? 'Nom complet' : 'Full Name',
                  style: TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: ar
                        ? 'أدخل الاسم'
                        : fr
                            ? 'Entrer le nom'
                            : 'Enter name',
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(card.radius),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return ar
                          ? 'الاسم مطلوب'
                          : fr
                              ? 'Nom requis'
                              : 'Name required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // EMAIL
                Text(
                  'Email',
                  style: TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'example@gmail.com',
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(card.radius),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return ar
                          ? 'البريد مطلوب'
                          : fr
                              ? 'Email requis'
                              : 'Email required';
                    }

                    final email = v.trim();

                    if (!email.contains('@') || !email.contains('.')) {
                      return ar
                          ? 'بريد غير صالح'
                          : fr
                              ? 'Email invalide'
                              : 'Invalid email';
                    }

                    if (!email.endsWith('@gmail.com')) {
                      return ar
                          ? 'فقط Gmail مسموح'
                          : fr
                              ? 'Gmail seulement'
                              : 'Gmail only';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // PHONE
                Text(
                  ar ? 'رقم الهاتف' : fr ? 'Téléphone' : 'Phone',
                  style: TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '+961  ',
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(card.radius),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return ar
                          ? 'رقم الهاتف مطلوب'
                          : fr
                              ? 'Téléphone requis'
                              : 'Phone required';
                    }

                    if (!RegExp(r'^[0-9]{8}$').hasMatch(v.trim())) {
                      return ar
                          ? 'يجب 8 أرقام'
                          : fr
                              ? '8 chiffres'
                              : '8 digits';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // PASSWORD
                Text(
                  ar ? 'كلمة المرور' : fr ? 'Mot de passe' : 'Password',
                  style: TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText :'XXXXXXXX', 

                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(card.radius),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.lock_outline
                            : Icons.lock_open_outlined,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return ar
                          ? 'كلمة المرور مطلوبة'
                          : fr
                              ? 'Mot de passe requis'
                              : 'Password required';
                    }

                    if (v.trim().length < 6) {
                      return ar
                          ? '6 أحرف على الأقل'
                          : fr
                              ? '6 caractères'
                              : 'Min 6 chars';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // BUTTON
                PrimaryButton(
                  label: ar
                      ? 'إنشاء الحساب'
                      : fr
                          ? 'Créer un compte'
                          : 'Register',
                  onPressed: () => _onSubmit(ar, fr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}