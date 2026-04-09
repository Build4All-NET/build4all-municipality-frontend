// lib/features/auth/presentation/login/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Screens
import 'package:baladiyati/features/auth/presentation/login/screens/reset_password_page.dart';
import 'package:baladiyati/features/auth/presentation/register/screens/user_register_screen.dart';
// Bloc
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

// Core
import '../../../../../core/config/app_sizes.dart';
import '../../../../../core/l10n/locale_cubit.dart';
import '../../../../../core/theme/theme_cubit.dart';

// Widgets
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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onLoginPressed(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final role = isCitizen ? 'CITIZEN' : 'EMPLOYEE';

    context.read<AuthBloc>().add(
          AuthLoginSubmitted(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text.trim(),
            role: role,
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

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
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
                        /// 🔹 TITLE
                        Center(
                          child: Text(
                            ar
                                ? 'تسجيل الدخول'
                                : fr
                                    ? 'Connexion'
                                    : 'Login',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// 🔹 SUBTITLE
                        Center(
                          child: Text(
                            ar
                                ? 'الوصول إلى حسابك في البلدية'
                                : fr
                                    ? 'Accédez à votre compte municipal'
                                    : 'Access your municipal account',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// 🔹 ROLE TOGGLE
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              _roleTab(
                                context,
                                ar
                                    ? 'موظف'
                                    : fr
                                        ? 'Employé'
                                        : 'Employee',
                                Icons.badge_outlined,
                                !isCitizen,
                                () => setState(() => isCitizen = false),
                              ),
                              _roleTab(
                                context,
                                ar
                                    ? 'مواطن'
                                    : fr
                                        ? 'Citoyen'
                                        : 'Citizen',
                                Icons.person_outline,
                                isCitizen,
                                () => setState(() => isCitizen = true),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// 🔹 EMAIL
                        Text(ar
                            ? 'البريد الإلكتروني'
                            : fr
                                ? 'Email'
                                : 'Email'),
                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            hintText: 'user@example.com',
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return ar
                                  ? 'البريد الإلكتروني مطلوب'
                                  : fr
                                      ? 'Email requis'
                                      : 'Email is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        /// 🔹 PASSWORD
                        Text(ar
                            ? 'كلمة المرور'
                            : fr
                                ? 'Mot de passe'
                                : 'Password'),
                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () => setState(() =>
                                  _obscurePassword = !_obscurePassword),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.lock_outline
                                    : Icons.lock_open_outlined,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return ar
                                  ? 'كلمة المرور مطلوبة'
                                  : fr
                                      ? 'Mot de passe requis'
                                      : 'Password is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        /// 🔹 FORGOT PASSWORD
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ResetPasswordPage(),
                                ),
                              );
                            },
                            child: Text(
                              ar
                                  ? 'هل نسيت كلمة المرور؟'
                                  : fr
                                      ? 'Mot de passe oublié ?'
                                      : 'Forgot password?',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// 🔹 LOGIN BUTTON
                        PrimaryButton(
                          label: ar
                              ? 'تسجيل الدخول'
                              : fr
                                  ? 'Se connecter'
                                  : 'Login',
                          isLoading: false,
                          onPressed: () => _onLoginPressed(context),
                        ),

                        const SizedBox(height: 20),

                        /// 🔹 REGISTER LINK
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ar
                                  ? 'ليس لديك حساب؟ '
                                  : fr
                                      ? "Vous n'avez pas de compte ? "
                                      : "Don't have an account? ",
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UserRegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                ar
                                    ? 'سجل الآن'
                                    : fr
                                        ? "S'inscrire"
                                        : 'Sign up',
                                style: TextStyle(
                                  color: colors.primary,
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
        ),
      ),
    );
  }

  /// 🔹 ROLE TAB WIDGET
  Widget _roleTab(
    BuildContext context,
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
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
              Icon(
                icon,
                color: selected ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
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