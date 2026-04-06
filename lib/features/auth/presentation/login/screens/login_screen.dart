// lib/features/auth/presentation/login/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../../core/config/app_colors.dart';
import '../../../../../core/config/app_sizes.dart';
import '../../../../../core/l10n/locale_cubit.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../../../../../core/exceptions/exception_mapper.dart';
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
  bool isEmail = true;

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
      password: _passwordCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final localeCubit = context.watch<LocaleCubit>();
    final themeState = context.watch<ThemeCubit>().state;
    final colors = themeState.tokens.colors;
    final card = themeState.tokens.card;
    final t = Theme.of(context).textTheme;
    final ar = localeCubit.isArabic;
    final fr = localeCubit.isFrench;

    String loginTitle = ar ? 'تسجيل الدخول' : fr ? 'Connexion' : 'Login';
    String loginSubtitle = ar ? 'الوصول إلى حسابك في البلدية' : fr ? 'Accédez à votre compte municipal' : 'Access your municipality account';
    String emailLabel = ar ? 'البريد الإلكتروني' : fr ? 'Email' : 'Email';
    String passwordLabel = ar ? 'كلمة المرور' : fr ? 'Mot de passe' : 'Password';
    String loginBtn = ar ? 'تسجيل الدخول' : fr ? 'Se connecter' : 'Login';
    String noAccount = ar ? 'ليس لديك حساب؟' : fr ? 'Pas de compte?' : "Don't have an account?";
    String registerNow = ar ? 'سجّل الآن' : fr ? "S'inscrire" : 'Register now';
    String citizenLabel = ar ? 'مواطن' : fr ? 'Citoyen' : 'Citizen';
    String employeeLabel = ar ? 'موظف' : fr ? 'Employé' : 'Employee';
    String emailMethod = ar ? 'بريد إلكتروني' : fr ? 'Email' : 'Email';
    String phoneMethod = ar ? 'هاتف' : fr ? 'Téléphone' : 'Phone';

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.isLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ar ? 'تم تسجيل الدخول بنجاح!' : fr ? 'Connexion réussie!' : 'Login successful!'),
              backgroundColor: Colors.green,
            ));
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ));
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingLarge,
                    vertical: AppSizes.paddingMedium,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Language selector
                      GestureDetector(
                        onTap: () {
                          final cubit = context.read<LocaleCubit>();
                          if (cubit.isArabic) cubit.setEnglish();
                          else if (cubit.isEnglish) cubit.setFrench();
                          else cubit.setArabic();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.border.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(20),
                            color: colors.surface,
                          ),
                          child: Row(children: [
                            Text(
                              ar ? 'العربية' : fr ? 'Français' : 'English',
                              style: TextStyle(fontSize: 13, color: colors.primary),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.language, size: 16, color: colors.primary),
                          ]),
                        ),
                      ),
                      // Logo
                      Row(children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('بلديتي',
                              style: t.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                              )),
                          Text(ar ? 'البلدية الرقمية' : 'Digital Municipality',
                              style: t.bodySmall?.copyWith(color: colors.body)),
                        ]),
                        const SizedBox(width: 10),
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.apartment, color: Colors.white, size: 26),
                        ),
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // White card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
                    child: Container(
                      padding: EdgeInsets.all(card.padding),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(card.radius),
                        boxShadow: card.showShadow ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: card.elevation * 4,
                            offset: const Offset(0, 4),
                          )
                        ] : null,
                        border: card.showBorder
                            ? Border.all(color: colors.border.withOpacity(0.2))
                            : null,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Title
                            Center(child: Text(loginTitle,
                                style: t.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.label,
                                ))),
                            const SizedBox(height: 6),
                            Center(child: Text(loginSubtitle,
                                style: t.bodyMedium?.copyWith(color: colors.body))),
                            const SizedBox(height: 24),

                            // مواطن / موظف
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: colors.background,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(children: [
                                _roleTab(employeeLabel, Icons.badge_outlined, !isCitizen, false, colors, () => setState(() => isCitizen = false)),
                                _roleTab(citizenLabel, Icons.person_outline, isCitizen, true, colors, () => setState(() => isCitizen = true)),
                              ]),
                            ),

                            const SizedBox(height: 16),

                            // Email / Phone toggle
                            Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: colors.background,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Row(children: [
                                _methodTab(emailMethod, isEmail, colors, () => setState(() => isEmail = true)),
                                _methodTab(phoneMethod, !isEmail, colors, () => setState(() => isEmail = false)),
                              ]),
                            ),

                            const SizedBox(height: 20),

                            // Email / Phone field
                            Text(isEmail ? emailLabel : (ar ? 'رقم الهاتف' : fr ? 'Téléphone' : 'Phone'),
                                style: t.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.label,
                                )),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(color: colors.label),
                              decoration: InputDecoration(
                                hintText: isEmail ? 'user@example.com' : '+961 xx xxx xxx',
                                hintStyle: TextStyle(color: colors.body),
                                suffixIcon: Icon(
                                  isEmail ? Icons.mail_outline : Icons.phone_outlined,
                                  color: colors.body,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return ar ? 'هذا الحقل مطلوب' : fr ? 'Ce champ est obligatoire' : 'Required';
                                }
                                return null;
                              },
                            ),

                            if (isEmail) ...[
                              const SizedBox(height: 16),
                              Text(passwordLabel,
                                  style: t.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.label,
                                  )),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                style: TextStyle(color: colors.label),
                                decoration: InputDecoration(
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                    child: Icon(
                                      _obscurePassword ? Icons.lock_outline : Icons.lock_open_outlined,
                                      color: colors.body,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return ar ? 'كلمة المرور مطلوبة' : fr ? 'Mot de passe requis' : 'Required';
                                  }
                                  if (v.length < 6) {
                                    return ar ? 'قصيرة جداً' : fr ? 'Trop court' : 'Too short';
                                  }
                                  return null;
                                },
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Login button
                            PrimaryButton(
                              label: state.isLoading ? '...' : loginBtn,
                              isLoading: state.isLoading,
                              onPressed: () => _onLoginPressed(context),
                            ),

                            const SizedBox(height: 16),

                            
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _roleTab(String label, IconData icon, bool selected, bool isBlue, dynamic colors, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? (isBlue ? colors.primary : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: selected && isBlue ? Colors.white : colors.label),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              color: selected && isBlue ? Colors.white : colors.label,
              fontWeight: FontWeight.w500,
            )),
          ]),
        ),
      ),
    );
  }

  Widget _methodTab(String label, bool selected, dynamic colors, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              fontSize: 13,
              color: selected ? colors.label : colors.body,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            )),
          ),
        ),
      ),
    );
  }
}
