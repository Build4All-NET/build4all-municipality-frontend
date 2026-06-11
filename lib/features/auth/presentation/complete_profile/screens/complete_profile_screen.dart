// lib/features/auth/presentation/complete_profile/screens/complete_profile_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/common/registration_step_cubit.dart';
import 'package:baladiyati/common/widgets/app_text_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/config/app_sizes.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/auth/data/services/api_auth_build4all_service.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();

  final _authApi = AuthApi(DioClient.build);
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('register_body');

    if (data == null || data.trim().isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(jsonDecode(data) as Map);
  }

  Future<void> _saveToPrefs(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('register_body', jsonEncode(body));
  }

  String _cleanError(Object e) {
    return e.toString().replaceAll('Exception:', '').trim();
  }

  Future<void> _pickImage() async {
    if (_isLoading) return;

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 900,
      maxHeight: 900,
    );

    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
    });
  }

  Future<void> _onSubmit(AppLocalizations l10n) async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final body = await _getFromPrefs();

      if (body == null) {
        throw Exception(l10n.missingRegistrationData);
      }

      // pendingId may be 0 or missing when Build4All verify-email-code
      // doesn't return a userId (e.g. "already verified" response).
      // Send it as-is; the Build4All API accepts 0 or ignores it.
      final pendingId = (body['pendingId'] ?? body['userId'] ?? '0').toString();
      final ownerProjectLinkId = (body['ownerProjectLinkId'] ?? '').toString();

      if (ownerProjectLinkId.isEmpty || ownerProjectLinkId == 'null') {
        throw Exception(l10n.missingOwnerProjectLinkId);
      }

      final firstName = _firstNameCtrl.text.trim();
      final lastName = _lastNameCtrl.text.trim();
      final username = _usernameCtrl.text.trim();

      await _authApi.ownerCompleteProfile(
        pendingId: pendingId,
        firstName: firstName,
        lastName: lastName,
        username: username,
        isPublicProfile: false,
        ownerProjectLinkId: ownerProjectLinkId,
        profileImagePath: _selectedImage?.path,
      );

      final updatedBody = {
        ...body,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'profileImagePath': _selectedImage?.path,
        'build4allProfileCompleted': true,
      };

      await _saveToPrefs(updatedBody);

      if (!mounted) return;

      setState(() => _isLoading = false);

      context.read<RegistrationStepCubit>().nextStep();

      AppToast.show(
        context,
        message: l10n.completeProfileSuccess,
        type: AppToastType.success,
      );

      AppRouter.goToLogin(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      AppToast.show(
        context,
        message: _cleanError(e),
        type: AppToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: cs.onSurface.withOpacity(0.07),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Center(
                          child: Text(
                            l10n.completeProfileTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        _buildImagePicker(context),

                        const SizedBox(height: 24),

                        AppTextField(
                          controller: _firstNameCtrl,
                          label: l10n.firstNameLabel,
                          hint: l10n.firstNameHint,
                          icon: Icons.badge_outlined,
                          textAlign: TextAlign.left,
                          validator: (v) {
                            final value = v?.trim() ?? '';

                            if (value.isEmpty) {
                              return l10n.fieldRequired;
                            }

                            if (value.length < 2) {
                              return l10n.firstNameTooShort;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        AppTextField(
                          controller: _lastNameCtrl,
                          label: l10n.lastNameLabel,
                          hint: l10n.lastNameHint,
                          icon: Icons.badge_outlined,
                          textAlign: TextAlign.left,
                          validator: (v) {
                            final value = v?.trim() ?? '';

                            if (value.isEmpty) {
                              return l10n.fieldRequired;
                            }

                            if (value.length < 2) {
                              return l10n.lastNameTooShort;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        AppTextField(
                          controller: _usernameCtrl,
                          label: l10n.usernameLabel,
                          hint: l10n.usernameHint,
                          icon: Icons.person_outline,
                          textAlign: TextAlign.left,
                          validator: (v) {
                            final value = v?.trim() ?? '';

                            if (value.isEmpty) {
                              return l10n.fieldRequired;
                            }

                            if (value.length < 3) {
                              return l10n.usernameTooShort;
                            }

                            final usernameRegex = RegExp(r'^[a-zA-Z0-9_\.]+$');

                            if (!usernameRegex.hasMatch(value)) {
                              return l10n.usernameInvalidChars;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        PrimaryButton(
                          label: l10n.completeProfileButton,
                          isLoading: _isLoading,
                          onPressed: () {
                            if (_isLoading) return;
                            _onSubmit(l10n);
                          },
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

  Widget _buildImagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _isLoading ? null : _pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: cs.primary.withOpacity(0.10),
                  backgroundImage:
                      _selectedImage != null ? FileImage(_selectedImage!) : null,
                  child: _selectedImage == null
                      ? Icon(
                          Icons.person_outline,
                          color: cs.primary,
                          size: 46,
                        )
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: cs.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 18,
                    color: cs.onPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          TextButton(
            onPressed: _isLoading ? null : _pickImage,
            child: Text(
              _selectedImage == null
                  ? l10n.chooseProfileImage
                  : l10n.changeProfileImage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          if (_selectedImage != null)
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
              child: Text(
                l10n.removeProfileImage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLarge,
        vertical: AppSizes.paddingMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _isLoading ? null : () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: cs.onSurface,
            ),
          ),
          Text(
            l10n.appTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
