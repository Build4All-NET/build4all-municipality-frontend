import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:baladiyati/features/auth/data/services/session_role_store.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/admin_profile_cubit.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      try {
        await DioClient.build.post('/auth/logout');
      } catch (_) {
        // Even if server logout fails, clear local session.
      }

      await const AdminTokenStore().clear();
      await AuthTokenStore().clear();
      await SessionRoleStore().clearRole();
      await JwtStore.clear();

      DioClient.clearAuthToken();

      if (!mounted) return;

      AppRouter.goToLogin(context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  String _dash() => '---';

  String _safeValue(String? value) {
    final clean = value?.trim() ?? '';
    return clean.isEmpty || clean == 'null' ? _dash() : clean;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<AdminProfileCubit, AdminProfileState>(
      listener: (context, state) {
        final error = state.error?.trim();

        if (error != null && error.isNotEmpty) {
          AppToast.show(
            context,
            message: error,
            type: AppToastType.error,
          );
        }
      },
      builder: (context, state) {
        final profile = state.profile;

        return Scaffold(
          appBar: AppBar(
            title: _ResponsiveOneLineText(
              text: loc.adminProfileTitle,
              maxFontSize: 20,
              minFontSize: 12,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
            actions: [
              IconButton(
                tooltip: loc.logout,
                onPressed: _isLoggingOut ? null : _logout,
                icon: _isLoggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
              ),
            ],
          ),
          body: state.isLoading && profile == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () {
                    return context.read<AdminProfileCubit>().loadProfile();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeaderCard(
                          title: _safeValue(profile?.fullName),
                          subtitle: _safeValue(profile?.role),
                        ),
                        const SizedBox(height: 18),
                        _SectionCard(
                          title: loc.accountInformation,
                          child: Column(
                            children: [
                              _InfoRow(
                                icon: Icons.person_outline,
                                label: loc.firstName,
                                value: _safeValue(profile?.firstName),
                              ),
                              _DividerLine(color: colors.outlineVariant),
                              _InfoRow(
                                icon: Icons.person_outline,
                                label: loc.lastName,
                                value: _safeValue(profile?.lastName),
                              ),
                              _DividerLine(color: colors.outlineVariant),
                              _InfoRow(
                                icon: Icons.alternate_email,
                                label: loc.usernameLabel,
                                value: _safeValue(profile?.username),
                              ),
                              _DividerLine(color: colors.outlineVariant),
                              _InfoRow(
                                icon: Icons.email_outlined,
                                label: loc.email,
                                value: _safeValue(profile?.email),
                              ),
                              _DividerLine(color: colors.outlineVariant),
                              _InfoRow(
                                icon: Icons.phone_outlined,
                                label: loc.phone,
                                value: _safeValue(profile?.phoneNumber),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: loc.profileDetails,
                          child: _InfoRow(
                            icon: Icons.verified_user_outlined,
                            label: loc.role,
                            value: _safeValue(profile?.role),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: colors.onPrimary.withOpacity(0.16),
            child: Icon(
              Icons.admin_panel_settings_outlined,
              color: colors.onPrimary,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResponsiveOneLineText(
                  text: title,
                  maxFontSize: 21,
                  minFontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: colors.onPrimary,
                ),
                const SizedBox(height: 5),
                _ResponsiveOneLineText(
                  text: subtitle,
                  maxFontSize: 14,
                  minFontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: colors.onPrimary.withOpacity(0.78),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withOpacity(0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResponsiveOneLineText(
            text: title,
            maxFontSize: 16,
            minFontSize: 10,
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: colors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 88,
            child: _ResponsiveOneLineText(
              text: label,
              maxFontSize: 13,
              minFontSize: 8,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _ResponsiveOneLineText(
                text: value,
                textAlign: TextAlign.end,
                maxFontSize: 14,
                minFontSize: 8,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  final Color color;

  const _DividerLine({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: color.withOpacity(0.45),
    );
  }
}

class _ResponsiveOneLineText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final double minFontSize;
  final double maxFontSize;
  final FontWeight fontWeight;
  final Color color;

  const _ResponsiveOneLineText({
    required this.text,
    this.textAlign = TextAlign.start,
    this.minFontSize = 9,
    this.maxFontSize = 14,
    this.fontWeight = FontWeight.normal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cleanText = text.trim().isEmpty ? '---' : text.trim();

    double fontSize = maxFontSize;
    final length = cleanText.runes.length;

    if (length > 45) {
      fontSize = maxFontSize - 6;
    } else if (length > 38) {
      fontSize = maxFontSize - 5;
    } else if (length > 31) {
      fontSize = maxFontSize - 4;
    } else if (length > 24) {
      fontSize = maxFontSize - 3;
    } else if (length > 17) {
      fontSize = maxFontSize - 2;
    } else if (length > 11) {
      fontSize = maxFontSize - 1;
    }

    if (fontSize < minFontSize) {
      fontSize = minFontSize;
    }

    Alignment alignment;

    if (textAlign == TextAlign.end || textAlign == TextAlign.right) {
      alignment = Alignment.centerRight;
    } else if (textAlign == TextAlign.center) {
      alignment = Alignment.center;
    } else {
      alignment = Alignment.centerLeft;
    }

    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: Text(
          cleanText,
          maxLines: 1,
          softWrap: false,
          textAlign: textAlign,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}