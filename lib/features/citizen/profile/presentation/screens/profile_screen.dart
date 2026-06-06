import 'dart:io';

import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/common/widgets/app_text_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/common/widgets/private_profile_avatar.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/core/l10n/locale_cubit.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/core/network/globals.dart' as globals;
import 'package:baladiyati/core/theme/theme_cubit.dart';
import 'package:baladiyati/core/utils/error_message.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:baladiyati/features/auth/data/services/session_role_store.dart';
import 'package:baladiyati/features/citizen/profile/domain/entities/profile_entity.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_bloc.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_event.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_state.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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
    if (_lastLoadedProfileId == profile.build4allId) {
      return;
    }

    _firstNameCtrl.text = profile.firstName;
    _lastNameCtrl.text = profile.lastName;
    _usernameCtrl.text = profile.username;
    _emailCtrl.text = profile.email;
    _phoneCtrl.text = profile.phone;
    _addressCtrl.text = profile.address;

    _lastLoadedProfileId = profile.build4allId;
  }

  String _dash() => '---';

  String _safeValue(String? value) {
    final clean = value?.trim() ?? '';
    return clean.isEmpty || clean == 'null' ? _dash() : clean;
  }

  String _municipalityLabel(ProfileEntity? profile) {
    final name = profile?.municipalityName?.trim();

    if (name != null && name.isNotEmpty && name != 'null') {
      return name;
    }

    // Fall back to the municipality/app name configured via ENV
    final appName = globals.appName.trim();
    if (appName.isNotEmpty) return appName;

    return _dash();
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

  String _fallbackText(ProfileEntity? profile) {
    final fullName = profile?.fullName.trim() ?? '';

    if (fullName.isNotEmpty) {
      return fullName;
    }

    final username = profile?.username.trim() ?? '';

    if (username.isNotEmpty) {
      return username;
    }

    final email = profile?.email.trim() ?? '';

    if (email.isNotEmpty) {
      return email;
    }

    return '?';
  }

  String? _profileImage(ProfileEntity? profile) {
    if (_imageRemoved) {
      return null;
    }

    final image = profile?.profilePictureUrl?.trim();

    if (image == null || image.isEmpty || image == 'null') {
      return null;
    }

    return image;
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

    if (picked == null) {
      return;
    }

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

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      try {
        await DioClient.build.post('/auth/logout');
      } catch (_) {
        // If backend logout fails, still clear local session.
      }

      await const AdminTokenStore().clear();
      await AuthTokenStore().clear();
      await SessionRoleStore().clearRole();
      await JwtStore.clear();

      DioClient.clearAuthToken();

      if (!mounted) return;

      AppToast.show(
        context,
        message: l10n.logout,
        type: AppToastType.success,
      );

      AppRouter.goToLogin(context);
    } catch (e) {
      if (!mounted) return;

      AppToast.show(
        context,
        message: errorMessage(e),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  void _showEditDialog(
    BuildContext context,
    AppLocalizations l10n,
    ProfileState state,
  ) {
    final profile = state.profile;

    if (profile == null) {
      return;
    }

    _selectedImage = null;
    _imageRemoved = false;

    final tokens = context.read<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, dialogSetState) {
            return AlertDialog(
              backgroundColor: colors.surface,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(card.radius),
              ),
              title: Text(
                l10n.editProfile,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: colors.label,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _pickImageInDialog(dialogSetState),
                      child: PrivateProfileAvatar(
                        imageUrl: _profileImage(profile),
                        localImage: _selectedImage,
                        fallbackText: _fallbackText(profile),
                        radius: 44,
                        backgroundColor: colors.primary.withOpacity(0.12),
                        textColor: colors.primary,
                        badge: Container(
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
                    if ((_profileImage(profile) != null) ||
                        _selectedImage != null)
                      TextButton(
                        onPressed: () => _removeImageInDialog(dialogSetState),
                        child: Text(
                          l10n.removeProfileImage,
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    SizedBox(height: card.padding),
                    AppTextField(
                      controller: _firstNameCtrl,
                      label: l10n.firstNameLabel,
                      hint: l10n.firstNameLabel,
                      icon: Icons.person_outline,
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: card.padding),
                    AppTextField(
                      controller: _lastNameCtrl,
                      label: l10n.lastNameLabel,
                      hint: l10n.lastNameLabel,
                      icon: Icons.person_outline,
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: card.padding),
                    AppTextField(
                      controller: _usernameCtrl,
                      label: l10n.usernameLabel,
                      hint: l10n.usernameLabel,
                      icon: Icons.alternate_email,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: card.padding),
                    AppTextField(
                      controller: _emailCtrl,
                      label: l10n.emailLabel,
                      hint: l10n.emailLabel,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: card.padding),
                    AppTextField(
                      controller: _phoneCtrl,
                      label: l10n.phoneLabel,
                      hint: l10n.phoneLabel,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: card.padding),
                    AppTextField(
                      controller: _addressCtrl,
                      label: l10n.addressLabel,
                      hint: l10n.addressLabel,
                      icon: Icons.location_on_outlined,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              actionsPadding: EdgeInsets.symmetric(
                horizontal: card.padding,
                vertical: card.padding * 0.75,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(card.radius),
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

          AppToast.show(
            context,
            message: l10n.changesSaved,
            type: AppToastType.success,
          );
        }

        final error = state.errorMessage?.trim();

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
                        ),
                        Padding(
                          padding: EdgeInsets.all(card.padding),
                          child: Column(
                            children: [
                              SizedBox(height: card.padding * 0.7),
                              _buildProfileTabs(
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
            colors.primary.withOpacity(0.76),
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        card.padding * 1.4,
        card.padding * 4.2,
        card.padding * 1.4,
        card.padding * 2.4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.myAccount,
            style: TextStyle(
              color: colors.onPrimary,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: card.padding * 1.5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _responsiveText(
                      text: profile?.fullName ?? _dash(),
                      color: colors.onPrimary,
                      maxFontSize: 20,
                      minFontSize: 14,
                      fontWeight: FontWeight.bold,
                      maxLines: 2,
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: card.padding * 0.4),
                    _responsiveText(
                      text: _municipalityLabel(profile),
                      color: colors.onPrimary.withOpacity(0.78),
                      maxFontSize: 13,
                      minFontSize: 10,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                    ),
                    if (profile?.username.isNotEmpty == true) ...[
                      SizedBox(height: card.padding * 0.35),
                      _responsiveText(
                        text: '@${profile!.username}',
                        color: colors.onPrimary.withOpacity(0.78),
                        maxFontSize: 12,
                        minFontSize: 9,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: card.padding),
              PrivateProfileAvatar(
                imageUrl: _profileImage(profile),
                localImage: null,
                fallbackText: _fallbackText(profile),
                radius: 39,
                backgroundColor: colors.onPrimary.withOpacity(0.20),
                textColor: colors.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTabs({
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
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(card.padding * 0.55),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(card.radius),
                ),
                child: TabBar(
                  labelColor: colors.onPrimary,
                  unselectedLabelColor: colors.body,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(card.radius),
                  ),
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: l10n.accountInfo),
                    Tab(text: l10n.municipalityInfo),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 390,
              child: TabBarView(
                children: [
                  _buildAccountInfoTab(
                    context: context,
                    l10n: l10n,
                    profile: profile,
                  ),
                  _buildMunicipalityInfoTab(
                    context: context,
                    l10n: l10n,
                    profile: profile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoTab({
    required BuildContext context,
    required AppLocalizations l10n,
    required ProfileEntity? profile,
  }) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _infoRow(
          context: context,
          icon: Icons.person_outline,
          label: l10n.fullNameLabel,
          value: _safeValue(profile?.fullName),
        ),
        _divider(context),
        _infoRow(
          context: context,
          icon: Icons.alternate_email,
          label: l10n.usernameLabel,
          value: _safeValue(profile?.username),
        ),
        _divider(context),
        _infoRow(
          context: context,
          icon: Icons.email_outlined,
          label: l10n.emailLabel,
          value: _safeValue(profile?.email),
        ),
        _divider(context),
        _infoRow(
          context: context,
          icon: Icons.verified_user_outlined,
          label: 'Status',
          value: _safeValue(profile?.coreStatus),
        ),
        _divider(context),
        _infoRow(
          context: context,
          icon: Icons.visibility_outlined,
          label: 'Visibility',
          value: profile?.isPublicProfile == true ? 'Public' : 'Private',
        ),
      ],
    );
  }

  Widget _buildMunicipalityInfoTab({
    required BuildContext context,
    required AppLocalizations l10n,
    required ProfileEntity? profile,
  }) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _infoRow(
          context: context,
          icon: Icons.account_balance_outlined,
          label: l10n.municipalityLabel,
          value: _municipalityLabel(profile),
        ),
        _divider(context),
        _infoRow(
          context: context,
          icon: Icons.phone_outlined,
          label: l10n.phoneLabel,
          value: _safeValue(profile?.phone),
        ),
        _divider(context),
        _infoRow(
          context: context,
          icon: Icons.location_on_outlined,
          label: l10n.addressLabel,
          value: _safeValue(profile?.address),
        ),
        _divider(context),
        _infoRow(
          context: context,
          icon: Icons.badge_outlined,
          label: l10n.municipalityStatus,
          value: _safeValue(profile?.municipalityStatus),
        ),
      ],
    );
  }

  Widget _buildEditButton({
    required BuildContext context,
    required AppLocalizations l10n,
    required ProfileState state,
  }) {
    final colors = context.watch<ThemeCubit>().state.tokens.colors;

    return PrimaryButton(
      label: l10n.editInfo,
      isLoading: state.isUpdating,
      backgroundColor: colors.primary,
      textColor: colors.onPrimary,
      onPressed: () {
        if (state.profile == null) {
          return;
        }

        _showEditDialog(context, l10n, state);
      },
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
        title: _responsiveText(
          text: l10n.selectLanguage,
          color: colors.label,
          maxFontSize: 14,
          minFontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _responsiveText(
              text: _languageName(currentLang),
              color: colors.body,
              maxFontSize: 13,
              minFontSize: 10,
            ),
            Icon(Icons.chevron_left, color: colors.muted),
          ],
        ),
      ),
    );
  }

 Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
  final colors = context.watch<ThemeCubit>().state.tokens.colors;

  return PrimaryButton(
    label: _isLoggingOut ? '...' : l10n.logout,
    isLoading: _isLoggingOut,
    backgroundColor: colors.danger,
    textColor: colors.onPrimary,
    onPressed: () {
      if (_isLoggingOut) return;
      _logout();
    },
  );
}

  Widget _divider(BuildContext context) {
    final colors = context.watch<ThemeCubit>().state.tokens.colors;

    return Divider(
      height: 1,
      indent: 18,
      endIndent: 18,
      color: colors.border.withOpacity(0.16),
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
        vertical: card.padding * 0.9,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.primary, size: 19),
          ),
          SizedBox(width: card.padding * 0.8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _responsiveText(
                  text: label,
                  color: colors.body,
                  maxFontSize: 11,
                  minFontSize: 9,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: card.padding * 0.25),
                _responsiveText(
                  text: value,
                  color: colors.label,
                  maxFontSize: 14,
                  minFontSize: 10,
                  fontWeight: FontWeight.w700,
                  maxLines: 2,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _responsiveText({
    required String text,
    required Color color,
    double maxFontSize = 14,
    double minFontSize = 10,
    int maxLines = 1,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.start,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final length = text.characters.length;

        double fontSize = maxFontSize;

        if (length > 35) {
          fontSize = maxFontSize - 3;
        } else if (length > 24) {
          fontSize = maxFontSize - 2;
        } else if (length > 16) {
          fontSize = maxFontSize - 1;
        }

        if (fontSize < minFontSize) {
          fontSize = minFontSize;
        }

        return Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: 1.25,
          ),
        );
      },
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