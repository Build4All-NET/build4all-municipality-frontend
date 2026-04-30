// lib/features/auth/presentation/login/screens/login_screen.dart

import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/admin_dashboard_placeholder_screen.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/api_auth_build4all_service.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:baladiyati/features/auth/data/services/session_role_store.dart';
import 'package:baladiyati/features/auth/data/services/auth_api_service.dart';
import 'package:baladiyati/features/auth/domain/facade/dual_login_orchestrator.dart';
import 'package:baladiyati/features/auth/presentation/municipality_profile/screens/municipality_profile_setup_screen.dart';
import 'package:baladiyati/features/auth/presentation/register/screens/user_register_screen.dart';
import 'package:baladiyati/features/citizen/home/presentation/screens/home_screen.dart';
import 'package:baladiyati/features/forgotpassword/presentation/screens/reset_password_page.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../common/widgets/app_text_field.dart';
import '../../../../../common/widgets/app_toast.dart';
import '../../../../../common/widgets/primary_button.dart';
import '../../../../../core/config/app_sizes.dart';
import '../../../../../core/theme/theme_cubit.dart';

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
  bool _isLoading = false;
  bool isCitizen = true;

  static int get ownerProjectLinkId {
    return int.tryParse(Env.ownerProjectLinkId) ?? 0;
  }

  final _authApi = AuthApi(DioClient.build);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _cleanError(Object e) {
    return e.toString().replaceAll('Exception:', '').trim();
  }

  Map<String, dynamic> _extractUserMap(DualLoginResult dual) {
    final data = dual.userData;

    if (data == null) {
      return <String, dynamic>{};
    }

    final user = data['user'];

    if (user is Map) {
      return Map<String, dynamic>.from(user);
    }

    return <String, dynamic>{};
  }

  int _extractUserId(Map<String, dynamic> userMap) {
    return int.tryParse(userMap['id']?.toString() ?? '') ?? 0;
  }

  String _municipalityProfileCompletedKey({
    required int ownerProjectLinkId,
    required int userId,
  }) {
    return 'municipality_profile_completed_${ownerProjectLinkId}_$userId';
  }

  Future<bool> _isMunicipalityProfileCompleted({
    required int ownerProjectLinkId,
    required int userId,
  }) async {
    if (ownerProjectLinkId <= 0 || userId <= 0) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(
          _municipalityProfileCompletedKey(
            ownerProjectLinkId: ownerProjectLinkId,
            userId: userId,
          ),
        ) ??
        false;
  }

  Future<void> _saveCitizenSession({
    required DualLoginResult dual,
    required Map<String, dynamic> userMap,
  }) async {
    final token = dual.userToken;

    if (token == null || token.trim().isEmpty) {
      throw Exception('Missing user token.');
    }

    await AdminTokenStore().clear();

    await JwtStore.save(token);

    await SessionRoleStore().saveRole('CITIZEN');

    await AuthTokenStore().saveToken(
      token: token,
      refreshToken: dual.userRefreshToken,
      tenantId: ownerProjectLinkId.toString(),
      userJson: userMap,
    );

    DioClient.setAuthToken(token);
  }

  Future<void> _goAfterCitizenLogin({
    required DualLoginResult dual,
    required String email,
  }) async {
    final userMap = _extractUserMap(dual);
    final userId = _extractUserId(userMap);

    await _saveCitizenSession(
      dual: dual,
      userMap: userMap,
    );

    final completed = await _isMunicipalityProfileCompleted(
      ownerProjectLinkId: ownerProjectLinkId,
      userId: userId,
    );

    if (!mounted) return;

    if (!completed) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MunicipalityProfileSetupScreen(
            build4allToken: dual.userToken!,
            ownerProjectLinkId: ownerProjectLinkId,
            build4allUser: userMap,
            fallbackEmail: email,
          ),
        ),
        (_) => false,
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  Future<void> _goAfterAdminLogin(DualLoginResult dual) async {
    if (dual.admin == null) {
      throw Exception('Missing admin login data.');
    }

    await AuthTokenStore().clear();
    await JwtStore.clear();

    await SessionRoleStore().saveRole(dual.admin!.role);

    await AdminTokenStore().save(
      token: dual.admin!.token,
      role: dual.admin!.role,
      refreshToken: dual.admin!.refreshToken,
      tenantId: ownerProjectLinkId.toString(),
    );

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminDashboardPlaceholderScreen(),
      ),
      (_) => false,
    );
  }

  Future<void> _onLoginPressed(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    setState(() => _isLoading = true);

    try {
      final dual = await DualLoginOrchestrator(
        authApi: _authApi,
        adminStore: AdminTokenStore(),
      ).login(
        identifier: email,
        password: password,
        ownerProjectLinkId: ownerProjectLinkId,
      );

      if (!mounted) return;

      if (dual.none) {
        AppToast.show(
          context,
          message: dual.error ?? l10n.loginFailed,
          type: AppToastType.error,
        );
        return;
      }

      if (dual.both) {
        setState(() => _isLoading = false);
        _showRoleChooser(context, dual);
        return;
      }

      if (dual.userOk) {
        await _goAfterCitizenLogin(
          dual: dual,
          email: email,
        );
        return;
      }

      if (dual.adminOk) {
        await _goAfterAdminLogin(dual);
        return;
      }
    } catch (e) {
      if (!mounted) return;

      AppToast.show(
        context,
        message: _cleanError(e),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRoleChooser(BuildContext context, DualLoginResult dual) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.chooseHowToContinue,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: Icon(Icons.person, color: cs.primary),
                  title: Text(
                    l10n.continueAsCitizen,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);

                    setState(() => _isLoading = true);

                    try {
                      await _goAfterCitizenLogin(
                        dual: dual,
                        email: _emailCtrl.text.trim(),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      AppToast.show(
                        context,
                        message: _cleanError(e),
                        type: AppToastType.error,
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                ),

                ListTile(
                  leading: Icon(Icons.admin_panel_settings, color: cs.primary),
                  title: Text(
                    l10n.continueAsAdmin,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);

                    setState(() => _isLoading = true);

                    try {
                      await _goAfterAdminLogin(dual);
                    } catch (e) {
                      if (!mounted) return;

                      AppToast.show(
                        context,
                        message: _cleanError(e),
                        type: AppToastType.error,
                      );
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final themeState = context.watch<ThemeCubit>().state;
    final colors = themeState.tokens.colors;
    final card = themeState.tokens.card;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                        Center(
                          child: Text(
                            l10n.loginTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            l10n.loginSubtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.outline,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: cs.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              _roleTab(
                                context,
                                l10n.employee,
                                Icons.badge_outlined,
                                !isCitizen,
                                () => setState(() => isCitizen = false),
                              ),
                              _roleTab(
                                context,
                                l10n.citizen,
                                Icons.person_outline,
                                isCitizen,
                                () => setState(() => isCitizen = true),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        AppTextField(
                          controller: _emailCtrl,
                          label: l10n.emailLabel,
                          hint: l10n.emailHint,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.left,
                          validator: (v) {
                            final value = v?.trim() ?? '';

                            if (value.isEmpty) {
                              return l10n.fieldRequired;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        AppTextField(
                          controller: _passwordCtrl,
                          label: l10n.passwordLabel,
                          hint: l10n.passwordHint,
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          textAlign: TextAlign.left,
                          suffixIcon: IconButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: cs.primary,
                            ),
                          ),
                          validator: (v) {
                            final value = v?.trim() ?? '';

                            if (value.isEmpty) {
                              return l10n.fieldRequired;
                            }

                            return null;
                          },
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ResetPasswordPage(),
                                      ),
                                    );
                                  },
                            child: Text(
                              l10n.forgotPassword,
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        PrimaryButton(
                          label: l10n.loginButton,
                          isLoading: _isLoading,
                          onPressed: () {
                            if (_isLoading) return;
                            _onLoginPressed(context);
                          },
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.noAccount,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const UserRegisterScreen(),
                                        ),
                                      );
                                    },
                              child: Text(
                                l10n.registerNow,
                                style: TextStyle(
                                  color: cs.primary,
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

  Widget _roleTab(
    BuildContext context,
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: _isLoading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? cs.primary : cs.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? cs.onPrimary : cs.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? cs.onPrimary : cs.onSurface,
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