// lib/features/welcome/presentation/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/app/app_router.dart';

import '../../../../core/l10n/locale_cubit.dart';
import '../../../../common/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary.withOpacity(0.85),
              cs.primary,
              cs.primary.withOpacity(0.65),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: cs.onPrimary.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Icon(
                          Icons.apartment,
                          size: 85,
                          color: cs.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 36),

                      Text(
                        l10n.appTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        l10n.appSubtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cs.onPrimary,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        l10n.appDescription,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onPrimary.withOpacity(0.70),
                        ),
                      ),

                      const SizedBox(height: 48),

                      PrimaryButton(
                        label: l10n.getStarted,
                        width: 220,
                        backgroundColor: cs.onPrimary,
                        textColor: cs.primary,
                        onPressed: () => AppRouter.goToLogin(context),
                      ),
                    ],
                  ),
                ),
              ),

              const Positioned(
                top: 16,
                right: 16,
                child: _LanguageSelector(),
              ),

              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Text(
                  l10n.copyright,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onPrimary.withOpacity(0.55),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCubit = context.watch<LocaleCubit>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: cs.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectLanguage,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Text('🇱🇧', style: TextStyle(fontSize: 24)),
                title: const Text('العربية'),
                selected: localeCubit.isArabic,
                selectedColor: cs.primary,
                onTap: () {
                  localeCubit.setArabic();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                selected: localeCubit.isEnglish,
                selectedColor: cs.primary,
                onTap: () {
                  localeCubit.setEnglish();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
                title: const Text('Français'),
                selected: localeCubit.isFrench,
                selectedColor: cs.primary,
                onTap: () {
                  localeCubit.setFrench();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.onPrimary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              localeCubit.isArabic
                  ? 'العربية'
                  : localeCubit.isFrench
                      ? 'Français'
                      : 'English',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.language, color: cs.onPrimary, size: 16),
          ],
        ),
      ),
    );
  }
}