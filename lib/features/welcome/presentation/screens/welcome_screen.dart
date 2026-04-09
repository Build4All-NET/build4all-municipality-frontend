import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import '../../../../core/l10n/locale_cubit.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../auth/presentation/login/screens/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCubit = context.watch<LocaleCubit>();
    final themeState = context.watch<ThemeCubit>().state;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 8, 46, 123),
              AppColors.primary,
              Color(0xFF1020A0),
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
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(Icons.apartment, size: 85, color: Colors.white),
                      ),
                      const SizedBox(height: 36),
                      Text(l10n.appTitle,
                          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Text(l10n.appSubtitle,
                          style: const TextStyle(fontSize: 20, color: Colors.white)),
                      const SizedBox(height: 14),
                      Text(l10n.appDescription,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 48),
                      PrimaryButton(
                        label: l10n.getStarted,
                        width: 220,
                        backgroundColor: Colors.white,
                        textColor: AppColors.primary,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(top: 16, right: 16, child: _LanguageSelector()),
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () => context.read<ThemeCubit>().toggleTheme(),
                  child: Icon(
                    themeState.isDark ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Text(l10n.copyright,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCubit = context.watch<LocaleCubit>();
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.selectLanguage,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Text('🇱🇧', style: TextStyle(fontSize: 24)),
                title: const Text('العربية'),
                selected: localeCubit.isArabic,
                onTap: () { localeCubit.setArabic(); Navigator.pop(context); },
              ),
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                selected: localeCubit.isEnglish,
                onTap: () { localeCubit.setEnglish(); Navigator.pop(context); },
              ),
              ListTile(
                leading: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
                title: const Text('Français'),
                selected: localeCubit.isFrench,
                onTap: () { localeCubit.setFrench(); Navigator.pop(context); },
              ),
            ],
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          Text(
            localeCubit.isArabic ? 'العربية' : localeCubit.isFrench ? 'Français' : 'English',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.language, color: Colors.white, size: 16),
        ]),
      ),
    );
  }
}
