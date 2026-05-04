// lib/features/citizen/profile/presentation/screens/profile_screen.dart

import 'dart:io';

import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/core/l10n/locale_cubit.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/core/theme/theme_cubit.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:baladiyati/features/auth/data/services/session_role_store.dart';
import 'package:baladiyati/features/auth/presentation/login/bloc/auth_bloc.dart';
import 'package:baladiyati/features/auth/presentation/login/bloc/auth_event.dart';
import 'package:baladiyati/features/citizen/profile/domain/entities/profile_entity.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_bloc.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_event.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_state.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _imageRemoved = false;
  bool _isLoggingOut = false;

  int? _lastLoadedProfileId;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileLoadRequested());
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _fillControllers(ProfileEntity profile) {
    if (_lastLoadedProfileId == profile.build4allId) return;

    _firstNameCtrl.text = profile.firstName;
    _lastNameCtrl.text = profile.lastName;
    _usernameCtrl.text = profile.username;
    _emailCtrl.text = profile.email;
    _phoneCtrl.text = profile.phone;
    _addressCtrl.text = profile.address;

    _lastLoadedProfileId = profile.build4allId;
  }

  String _notAvailable() {
    return '---';
  }

  String _municipalityLabel(ProfileEntity? profile, AppLocalizations l10n) {
    final name = profile?.municipalityName?.trim();

    if (name != null && name.isNotEmpty) return name;

    final id = profile?.municipalityId;
    if (id != null && id > 0) {
      return '${l10n.municipalityLabel} #$id';
    }

    return _notAvailable();
  }

  String _languageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  String? _resolveProfileImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;

    final url = rawUrl.trim();

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (!url.startsWith('/')) return url;

    final base = DioClient.build.options.baseUrl;

    final root = base.endsWith('/api')
        ? base.substring(0, base.length - 4)
        : base.replaceFirst(RegExp(r'/api/?$'), '');

    return '$root$url';
  }

  ImageProvider? _profileImageProvider(ProfileEntity? profile) {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }

    if (_imageRemoved) {
      return null;
    }

    final url = _resolveProfileImageUrl(profile?.profilePictureUrl);

    if (url == null || url.isEmpty) return null;

    return NetworkImage(url);
  }

  String _initials(ProfileEntity? profile) {
    final name = profile?.fullName.trim() ?? '';

    if (name.isNotEmpty) {
      return name.characters.first.toUpperCase();
    }

    final email = profile?.email.trim() ?? '';

    if (email.isNotEmpty) {
      return email.characters.first.toUpperCase();
    }

    return '?';
  }

  Future<void> _pickImageInDialog(
    void Function(void Function()) dialogSetState,
  ) async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 900,
      maxHeight: 900,
    );

    if (picked == null) return;

    dialogSetState(() {
      _selectedImage = File(picked.path);
      _imageRemoved = false;
    });

    setState(() {});
  }

  void _removeImageInDialog(
    void Function(void Function()) dialogSetState,
  ) {
    dialogSetState(() {
      _selectedImage = null;
      _imageRemoved = true;
    });

    setState(() {});
  }

  Future<void> _logout(BuildContext context) async {
    if (_isLoggingOut) return;

    final authBloc = context.read<AuthBloc>();

    setState(() => _isLoggingOut = true);

    try {
      authBloc.add(AuthLoggedOut());

      await AuthTokenStore().clearToken();
      await AdminTokenStore().clear();
      await JwtStore.clear();

      await SessionRoleStore().saveRole('');

      DioClient.setAuthToken('');

      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('token');
      await prefs.remove('accessToken');
      await prefs.remove('authToken');
      await prefs.remove('auth_token');
      await prefs.remove('userToken');
      await prefs.remove('build4allToken');
      await prefs.remove('userId');
      await prefs.remove('build4allUserId');
      await prefs.remove('currentUserId');

      if (!mounted) return;

      AppRouter.goToWelcome(context);
    } catch (_) {
      if (!mounted) return;

      AppRouter.goToWelcome(context);
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  void _showEditDialog(
    BuildContext context,
    AppLocalizations l10n,
    ProfileState state,
  ) {
    final profile = state.profile;
    if (profile == null) return;

    _selectedImage = null;
    _imageRemoved = false;

    final tokens = context.read<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;
    final button = tokens.button;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, dialogSetState) {
            final imageProvider = _profileImageProvider(profile);

            return AlertDialog(
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(card.radius),
              ),
              title: Text(
                l10n.editProfile,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colors.label,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _pickImageInDialog(dialogSetState),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: colors.primary.withOpacity(0.12),
                            backgroundImage: imageProvider,
                            child: imageProvider == null
                                ? Text(
                                    _initials(profile),
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          Container(
                            padding: EdgeInsets.all(card.padding * 0.55),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.surface,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 17,
                              color: colors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: card.padding * 0.75),
                    TextButton(
                      onPressed: () => _pickImageInDialog(dialogSetState),
                      child: Text(
                        _selectedImage == null
                            ? l10n.chooseProfileImage
                            : l10n.changeProfileImage,
                        style: TextStyle(color: colors.primary),
                      ),
                    ),
                    if (profile.profilePictureUrl != null ||
                        _selectedImage != null)
                      TextButton(
                        onPressed: () => _removeImageInDialog(dialogSetState),
                        child: Text(
                          l10n.removeProfileImage,
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    SizedBox(height: card.padding),
                    _editField(
                      context: context,
                      label: l10n.firstNameLabel,
                      controller: _firstNameCtrl,
                    ),
                    SizedBox(height: card.padding),
                    _editField(
                      context: context,
                      label: l10n.lastNameLabel,
                      controller: _lastNameCtrl,
                    ),
                    SizedBox(height: card.padding),
                    _editField(
                      context: context,
                      label: l10n.usernameLabel,
                      controller: _usernameCtrl,
                      isLtr: true,
                    ),
                    SizedBox(height: card.padding),
                    _editField(
                      context: context,
                      label: l10n.emailLabel,
                      controller: _emailCtrl,
                      isLtr: true,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: card.padding),
                    _editField(
                      context: context,
                      label: l10n.phoneLabel,
                      controller: _phoneCtrl,
                      isLtr: true,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: card.padding),
                    _editField(
                      context: context,
                      label: l10n.addressLabel,
                      controller: _addressCtrl,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: colors.body),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    minimumSize: Size(90, button.height),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(button.radius),
                    ),
                  ),
                  onPressed: state.isUpdating
                      ? null
                      : () {
                          Navigator.pop(dialogContext);

                          context.read<ProfileBloc>().add(
                                ProfileUpdateSubmitted(
                                  firstName: _firstNameCtrl.text.trim(),
                                  lastName: _lastNameCtrl.text.trim(),
                                  username: _usernameCtrl.text.trim(),
                                  email: _emailCtrl.text.trim(),
                                  phone: _phoneCtrl.text.trim(),
                                  address: _addressCtrl.text.trim(),
                                  profileImagePath: _selectedImage?.path,
                                  imageRemoved: _imageRemoved,
                                ),
                              );
                        },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _editField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    bool isLtr = false,
    TextInputType? keyboardType,
  }) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colors.body,
          ),
        ),
        SizedBox(height: card.padding * 0.35),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: isLtr ? TextAlign.left : TextAlign.right,
          textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
          style: TextStyle(
            color: colors.label,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(card.radius),
              borderSide: BorderSide(color: colors.border.withOpacity(0.35)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(card.radius),
              borderSide: BorderSide(color: colors.border.withOpacity(0.35)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(card.radius),
              borderSide: BorderSide(
                color: colors.primary,
                width: 1.4,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: card.padding,
              vertical: card.padding * 0.75,
            ),
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

    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.profile != null) {
          _fillControllers(state.profile!);
        }

        if (state.isUpdateSuccess && state.profile != null) {
          _selectedImage = null;
          _imageRemoved = false;
          _lastLoadedProfileId = null;
          _fillControllers(state.profile!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.changesSaved),
              backgroundColor: colors.success,
            ),
          );
        }

        if (state.errorMessage != null &&
            state.errorMessage!.trim().isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: colors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        final imageProvider = _profileImageProvider(profile);

        return Scaffold(
          backgroundColor: colors.background,
          body: state.isLoading
              ? Center(
                  child: CircularProgressIndicator(color: colors.primary),
                )
              : RefreshIndicator(
                  color: colors.primary,
                  onRefresh: () async {
                    context.read<ProfileBloc>().add(ProfileLoadRequested());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(
                          context: context,
                          l10n: l10n,
                          profile: profile,
                          imageProvider: imageProvider,
                        ),
                        Padding(
                          padding: EdgeInsets.all(card.padding),
                          child: Column(
                            children: [
                              SizedBox(height: card.padding * 0.5),
                              _buildInfoCard(
                                context: context,
                                l10n: l10n,
                                profile: profile,
                              ),
                              SizedBox(height: card.padding),
                              _buildEditButton(
                                context: context,
                                l10n: l10n,
                                state: state,
                              ),
                              SizedBox(height: card.padding),
                              _buildLanguageCard(
                                context: context,
                                l10n: l10n,
                                localeCubit: localeCubit,
                                currentLang: currentLang,
                              ),
                              SizedBox(height: card.padding * 1.5),
                              _buildLogoutButton(context, l10n),
                              SizedBox(height: card.padding * 1.5),
                            ],
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

  Widget _buildHeader({
    required BuildContext context,
    required AppLocalizations l10n,
    required ProfileEntity? profile,
    required ImageProvider? imageProvider,
  }) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.primary.withOpacity(0.75),
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        card.padding * 1.6,
        card.padding * 4.5,
        card.padding * 1.6,
        card.padding * 3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.myAccount,
            style: TextStyle(
              color: colors.onPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: card.padding * 1.6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      profile?.fullName ?? _notAvailable(),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: card.padding * 0.35),
                    Text(
                      _municipalityLabel(profile, l10n),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onPrimary.withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),
                    if (profile?.username.isNotEmpty == true) ...[
                      SizedBox(height: card.padding * 0.35),
                      Text(
                        '@${profile!.username}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: colors.onPrimary.withOpacity(0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: card.padding),
              CircleAvatar(
                radius: 38,
                backgroundColor: colors.onPrimary.withOpacity(0.20),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Text(
                        _initials(profile),
                        style: TextStyle(
                          color: colors.onPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required ProfileEntity? profile,
  }) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(card.radius),
        border: card.showBorder
            ? Border.all(color: colors.border.withOpacity(0.18))
            : null,
        boxShadow: card.showShadow
            ? [
                BoxShadow(
                  color: colors.border.withOpacity(0.08),
                  blurRadius: card.elevation * 3,
                  offset: Offset(0, card.elevation * 0.8),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          _infoRow(
            context: context,
            icon: Icons.person_outline,
            label: l10n.usernameLabel,
            value: profile?.username.isNotEmpty == true
                ? profile!.username
                : _notAvailable(),
          ),
          _divider(context),
          _infoRow(
            context: context,
            icon: Icons.phone_outlined,
            label: l10n.phoneLabel,
            value: profile?.phone.isNotEmpty == true
                ? profile!.phone
                : _notAvailable(),
          ),
          _divider(context),
          _infoRow(
            context: context,
            icon: Icons.email_outlined,
            label: l10n.emailLabel,
            value: profile?.email.isNotEmpty == true
                ? profile!.email
                : _notAvailable(),
          ),
          _divider(context),
          _infoRow(
            context: context,
            icon: Icons.location_on_outlined,
            label: l10n.addressLabel,
            value: profile?.address.isNotEmpty == true
                ? profile!.address
                : _notAvailable(),
          ),
          _divider(context),
          _infoRow(
            context: context,
            icon: Icons.apartment_outlined,
            label: l10n.municipalityLabel,
            value: _municipalityLabel(profile, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton({
    required BuildContext context,
    required AppLocalizations l10n,
    required ProfileState state,
  }) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;
    final button = tokens.button;

    return SizedBox(
      width: double.infinity,
      child: state.isUpdating
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary),
                padding: EdgeInsets.symmetric(vertical: card.padding),
                minimumSize: Size.fromHeight(button.height),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(button.radius),
                ),
              ),
              onPressed: state.profile == null
                  ? null
                  : () => _showEditDialog(context, l10n, state),
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.editInfo),
            ),
    );
  }

  Widget _buildLanguageCard({
    required BuildContext context,
    required AppLocalizations l10n,
    required LocaleCubit localeCubit,
    required String currentLang,
  }) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(card.radius),
        border: card.showBorder
            ? Border.all(color: colors.border.withOpacity(0.18))
            : null,
        boxShadow: card.showShadow
            ? [
                BoxShadow(
                  color: colors.border.withOpacity(0.08),
                  blurRadius: card.elevation * 3,
                  offset: Offset(0, card.elevation * 0.8),
                ),
              ]
            : null,
      ),
      child: ListTile(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(card.radius),
              ),
            ),
            builder: (_) => _LanguagePicker(localeCubit: localeCubit),
          );
        },
        leading: Icon(Icons.language, color: colors.muted),
        title: Text(
          l10n.selectLanguage,
          style: TextStyle(color: colors.label),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _languageName(currentLang),
              style: TextStyle(color: colors.body),
            ),
            Icon(Icons.chevron_left, color: colors.muted),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final button = tokens.button;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.danger,
          foregroundColor: colors.onPrimary,
          minimumSize: Size.fromHeight(button.height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(button.radius),
          ),
        ),
        onPressed: _isLoggingOut ? null : () => _logout(context),
        icon: _isLoggingOut
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.onPrimary,
                ),
              )
            : const Icon(Icons.logout),
        label: Text(_isLoggingOut ? '...' : l10n.logout),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final colors = context.watch<ThemeCubit>().state.tokens.colors;

    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: colors.border.withOpacity(0.18),
    );
  }

  Widget _infoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: card.padding,
        vertical: card.padding,
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.muted, size: 20),
          const Spacer(),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.body,
                  ),
                ),
                SizedBox(height: card.padding * 0.25),
                Text(
                  value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.label,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  final LocaleCubit localeCubit;

  const _LanguagePicker({
    required this.localeCubit,
  });

  String _languageTitle(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;

    return Padding(
      padding: EdgeInsets.all(card.padding * 1.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.selectLanguage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.label,
            ),
          ),
          SizedBox(height: card.padding),
          _langTile(context, _languageTitle('ar'), 'ar'),
          _langTile(context, _languageTitle('en'), 'en'),
          _langTile(context, _languageTitle('fr'), 'fr'),
          SizedBox(height: card.padding * 0.5),
        ],
      ),
    );
  }

  Widget _langTile(
    BuildContext context,
    String label,
    String code,
  ) {
    final isSelected = localeCubit.currentLanguageCode == code;
    final colors = context.watch<ThemeCubit>().state.tokens.colors;

    return ListTile(
      onTap: () {
        localeCubit.setLocale(Locale(code));
        Navigator.pop(context);
      },
      title: Text(
        label,
        style: TextStyle(color: colors.label),
      ),
      trailing: isSelected ? Icon(Icons.check, color: colors.primary) : null,
    );
  }
}