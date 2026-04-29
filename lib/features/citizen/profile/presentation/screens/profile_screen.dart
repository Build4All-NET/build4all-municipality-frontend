// lib/features/citizen/profile/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/core/l10n/locale_cubit.dart';
import 'package:baladiyati/features/auth/presentation/login/bloc/auth_bloc.dart';
import 'package:baladiyati/features/auth/presentation/login/bloc/auth_event.dart';
import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_bloc.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_event.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load real profile from API
    context.read<ProfileBloc>().add(ProfileLoadRequested());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  void _fillControllers(ProfileState state) {
    if (state.profile != null) {
      _nameCtrl.text = state.profile!.fullName ?? '';
      _phoneCtrl.text = state.profile!.phone ?? '';
      _addressCtrl.text = state.profile!.address ?? '';
      _usernameCtrl.text = state.profile!.username ?? '';
    }
  }

  void _showEditDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.editProfile, textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _editField(l10n.fullNameLabel, _nameCtrl),
            const SizedBox(height: 12),
            _editField(l10n.phoneLabel, _phoneCtrl, isLtr: true),
            const SizedBox(height: 12),
            _editField(l10n.addressLabel, _addressCtrl),
            const SizedBox(height: 12),
            _editField(l10n.usernameLabel, _usernameCtrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Call real API to update profile
              context.read<ProfileBloc>().add(ProfileUpdateSubmitted(
                fullName: _nameCtrl.text.trim(),
                phone: _phoneCtrl.text.trim(),
                address: _addressCtrl.text.trim(),
                username: _usernameCtrl.text.trim(),
              ));
            },
            child: Text(l10n.save,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _editField(String label, TextEditingController ctrl,
      {bool isLtr = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          textAlign: isLtr ? TextAlign.left : TextAlign.right,
          textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCubit = context.watch<LocaleCubit>();
    final currentLang = localeCubit.currentLanguageCode;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        // Fill controllers when profile loaded
        if (state.profile != null) {
          _fillControllers(state);
        }

        // Show success message after update
        if (state.isUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.changesSaved),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Show error
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1E3A5F)))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // ── Header gradient ──────────────────────
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E3A5F), Color(0xFF2F6FED)],
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.myAccount,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      // ✅ Real name from API
                                      state.profile?.fullName ?? '---',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'بلدية بيروت',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      // ✅ First letter of name
                                      state.profile?.fullName?.isNotEmpty == true
                                          ? state.profile!.fullName![0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),

                            // ── Info card ────────────────────────
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  //  Real phone from API
                                  _infoRow(
                                      Icons.phone_outlined,
                                      l10n.phoneLabel,
                                      state.profile?.phone ?? '---'),
                                  const Divider(
                                      height: 1, indent: 16, endIndent: 16),
                                  //  Real email from API
                                  _infoRow(
                                      Icons.email_outlined,
                                      l10n.emailLabel,
                                      state.profile?.email ?? '---'),
                                  const Divider(
                                      height: 1, indent: 16, endIndent: 16),
                                  // Real address from API
                                  _infoRow(
                                      Icons.location_on_outlined,
                                      l10n.addressLabel,
                                      state.profile?.address ?? '---'),
                                  const Divider(
                                      height: 1, indent: 16, endIndent: 16),
                                  _infoRow(
                                      Icons.apartment_outlined,
                                      l10n.municipalityLabel,
                                      'بلدية بيروت'),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ── Edit button ──────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: state.isUpdating
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      onPressed: () =>
                                          _showEditDialog(context, l10n),
                                      icon: const Icon(Icons.edit_outlined),
                                      label: Text(l10n.editInfo),
                                    ),
                            ),

                            const SizedBox(height: 12),

                            // ── Language card ────────────────────
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    builder: (_) => _LanguagePicker(
                                        localeCubit: localeCubit),
                                  );
                                },
                                leading: const Icon(Icons.language,
                                    color: Colors.grey),
                                title: Text(l10n.selectLanguage),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currentLang == 'ar'
                                          ? 'العربية'
                                          : currentLang == 'fr'
                                              ? 'Français'
                                              : 'English',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                    const Icon(Icons.chevron_left,
                                        color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Logout button ────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  context
                                      .read<AuthBloc>()
                                      .add(AuthLoggedOut());
                                  AppRouter.goToWelcome(context);
                                },
                                icon: const Icon(Icons.logout),
                                label: Text(l10n.logout),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  final LocaleCubit localeCubit;
  const _LanguagePicker({required this.localeCubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.selectLanguage,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _langTile(context, 'العربية', 'ar'),
          _langTile(context, 'English', 'en'),
          _langTile(context, 'Français', 'fr'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _langTile(BuildContext context, String label, String code) {
    final isSelected = localeCubit.currentLanguageCode == code;
    return ListTile(
      onTap: () {
        localeCubit.setLocale(Locale(code));
        Navigator.pop(context);
      },
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF1E3A5F))
          : null,
    );
  }
}
