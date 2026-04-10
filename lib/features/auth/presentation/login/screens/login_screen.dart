import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/features/auth/presentation/login/screens/reset_password_page.dart';
import 'package:baladiyati/features/auth/presentation/register/screens/user_register_screen.dart';
import 'package:baladiyati/features/auth/presentation/complete_profile/screens/complete_profile_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../../core/config/app_sizes.dart';
import '../../../../../core/theme/theme_cubit.dart';
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
    context.read<AuthBloc>().add(AuthLoginSubmitted(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      role: isCitizen ? 'CITIZEN' : 'EMPLOYEE',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = context.watch<ThemeCubit>().state;
    final colors = themeState.tokens.colors;
    final card = themeState.tokens.card;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            // ✅ Show error message
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }

            // ✅ Navigate to CompleteProfile after login success
            if (state.isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.successLogin),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );

              // Navigate to CompleteProfile screen
              Future.delayed(const Duration(milliseconds: 500), () {
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompleteProfileScreen(),
                  ),
                  (_) => false,
                );
              });
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingLarge),
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

                            // TITLE
                            Center(
                              child: Text(l10n.loginTitle,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),

                            // SUBTITLE
                            Center(
                              child: Text(l10n.loginSubtitle,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                            ),
                            const SizedBox(height: 24),

                            // ROLE TOGGLE
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(children: [
                                _roleTab(
                                    context,
                                    l10n.employee,
                                    Icons.badge_outlined,
                                    !isCitizen,
                                    () => setState(() => isCitizen = false)),
                                _roleTab(
                                    context,
                                    l10n.citizen,
                                    Icons.person_outline,
                                    isCitizen,
                                    () => setState(() => isCitizen = true)),
                              ]),
                            ),
                            const SizedBox(height: 20),

                            // EMAIL
                            Text(l10n.emailLabel),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration:
                                  InputDecoration(hintText: l10n.emailHint),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return l10n.fieldRequired;
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // PASSWORD
                            Text(l10n.passwordLabel),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: l10n.passwordHint,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                  icon: Icon(_obscurePassword
                                      ? Icons.lock_outline
                                      : Icons.lock_open_outlined),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return l10n.fieldRequired;
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),

                            // FORGOT PASSWORD
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ResetPasswordPage())),
                                child: Text(l10n.forgotPassword,
                                    style: TextStyle(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline)),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // ✅ LOGIN BUTTON — now uses state.isLoading
                            PrimaryButton(
                              label: l10n.loginButton,
                              isLoading: state.isLoading, // ✅ FIXED
                              onPressed: state.isLoading
                                  ? () {} // disabled while loading
                                  : () => _onLoginPressed(context),
                            ),
                            const SizedBox(height: 20),

                            // REGISTER LINK
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(l10n.noAccount),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const UserRegisterScreen())),
                                  child: Text(l10n.registerNow,
                                      style: TextStyle(
                                          color: colors.primary,
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                              TextDecoration.underline)),
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

  Widget _roleTab(BuildContext context, String label, IconData icon,
      bool selected, VoidCallback onTap) {
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
              Icon(icon, color: selected ? Colors.white : Colors.black87),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
