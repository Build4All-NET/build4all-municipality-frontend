// lib/features/auth/presentation/municipality_profile/screens/municipality_profile_setup_screen.dart

import 'package:baladiyati/common/widgets/app_text_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/config/app_sizes.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/core/theme/theme_cubit.dart';
import 'package:baladiyati/features/citizen/home/presentation/screens/home_screen.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MunicipalityProfileSetupScreen extends StatefulWidget {
  final String build4allToken;
  final int ownerProjectLinkId;
  final Map<String, dynamic> build4allUser;
  final String fallbackEmail;

  const MunicipalityProfileSetupScreen({
    super.key,
    required this.build4allToken,
    required this.ownerProjectLinkId,
    required this.build4allUser,
    required this.fallbackEmail,
  });

  @override
  State<MunicipalityProfileSetupScreen> createState() =>
      _MunicipalityProfileSetupScreenState();
}

class _MunicipalityProfileSetupScreenState
    extends State<MunicipalityProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  final Dio _dio = DioClient.muni;

  bool _isLoading = false;

  static const _staticMunicipality = _MunicipalityOption(
    id: 3,
    nameAr: 'بلدية صيدا',
    nameEn: 'Saida Municipality',
  );

  _MunicipalityOption? _selectedMunicipality = _staticMunicipality;

  @override
  void initState() {
    super.initState();
    _prefillUserPhone();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _prefillUserPhone() {
    final phone = (widget.build4allUser['phoneNumber'] ??
            widget.build4allUser['phone'] ??
            '')
        .toString()
        .trim();

    if (phone.isNotEmpty && phone != 'null') {
      _phoneCtrl.text = phone;
    }
  }

  String _cleanError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;

      if (data is Map) {
        final message = data['message'] ?? data['error'];
        if (message != null) return message.toString();
      }
    }

    return e.toString().replaceAll('Exception:', '').trim();
  }

  String _bearerToken() {
    final token = widget.build4allToken.trim();

    if (token.toLowerCase().startsWith('bearer ')) {
      return token;
    }

    return 'Bearer $token';
  }

  String _email() {
    return (widget.build4allUser['email'] ?? widget.fallbackEmail)
        .toString()
        .trim();
  }

  int _userId() {
    return int.tryParse(widget.build4allUser['id']?.toString() ?? '') ?? 0;
  }

  String _fullName() {
    final firstName = (widget.build4allUser['firstName'] ?? '').toString();
    final lastName = (widget.build4allUser['lastName'] ?? '').toString();

    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) return fullName;

    final username = (widget.build4allUser['username'] ?? '').toString().trim();

    if (username.isNotEmpty) return username;

    return _email().split('@').first;
  }

  String _completionPrefsKey() {
    return 'municipality_profile_completed_${widget.ownerProjectLinkId}_${_userId()}';
  }

  Future<void> _markMunicipalityProfileCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completionPrefsKey(), true);
  }

  bool _isAlreadyExistsError(Object e) {
    if (e is! DioException) return false;

    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (status == 409) return true;

    if (data is Map) {
      final code = (data['code'] ?? '').toString().toUpperCase();
      final message = (data['message'] ?? data['error'] ?? '')
          .toString()
          .toLowerCase();

      return code.contains('EMAIL_ALREADY_EXISTS') ||
          code.contains('USER_ALREADY_EXISTS') ||
          message.contains('already') ||
          message.contains('email already');
    }

    return false;
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    final selectedMunicipality = _selectedMunicipality;

    if (selectedMunicipality == null) {
      AppToast.show(
        context,
        message: l10n.selectMunicipalityWarning,
        type: AppToastType.error,
      );
      return;
    }

    if (widget.build4allToken.trim().isEmpty) {
      AppToast.show(
        context,
        message: l10n.missingBuild4allToken,
        type: AppToastType.error,
      );
      return;
    }

    if (_email().isEmpty) {
      AppToast.show(
        context,
        message: l10n.missingBuild4allUser,
        type: AppToastType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _dio.post(
        '/auth/users/register',
        options: Options(
          headers: {
            'Authorization': _bearerToken(),
            'Owner-Project-Link-Id': widget.ownerProjectLinkId.toString(),
            'X-Owner-Project-Link-Id': widget.ownerProjectLinkId.toString(),
          },
        ),
        data: {
          'email': _email(),
          'passwordHash': 'BUILD4ALL_USER',
          'fullName': _fullName(),
          'phone': _phoneCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'role': 'USER',
          'municipality': {
            'id': selectedMunicipality.id,
          },
        },
      );

      await _markMunicipalityProfileCompleted();

      if (!mounted) return;

      AppToast.show(
        context,
        message: l10n.municipalityProfileSaved,
        type: AppToastType.success,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      if (_isAlreadyExistsError(e)) {
        await _markMunicipalityProfileCompleted();

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
        return;
      }

      if (!mounted) return;

      final message = _cleanError(e);

      AppToast.show(
        context,
        message: message.isEmpty ? l10n.municipalityProfileSaveFailed : message,
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _municipalityLabel(_MunicipalityOption item, AppLocalizations l10n) {
    if (l10n.localeName == 'ar') {
      return item.nameAr;
    }

    return item.nameEn;
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
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: Container(
                  padding: EdgeInsets.all(card.padding),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(card.radius),
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
                            l10n.municipalityProfileTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            l10n.municipalityProfileSubtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.outline,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        AppTextField(
                          controller: _phoneCtrl,
                          label: l10n.phoneLabel,
                          hint: l10n.phoneHint,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.left,
                          validator: (v) {
                            final value = v?.trim() ?? '';

                            if (value.isEmpty) {
                              return l10n.fieldRequired;
                            }

                            if (!RegExp(r'^[0-9]{8,15}$').hasMatch(value)) {
                              return l10n.phoneInvalid;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        AppTextField(
                          controller: _addressCtrl,
                          label: l10n.addressLabel,
                          hint: l10n.addressHint,
                          icon: Icons.location_on_outlined,
                          textAlign: TextAlign.left,
                          validator: (v) {
                            final value = v?.trim() ?? '';

                            if (value.isEmpty) {
                              return l10n.fieldRequired;
                            }

                            if (value.length < 6) {
                              return l10n.addressTooShort;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildMunicipalityDropdown(context, l10n),

                        const SizedBox(height: 28),

                        PrimaryButton(
                          label: l10n.completeMunicipalityProfileButton,
                          isLoading: _isLoading,
                          onPressed: () {
                            if (_isLoading) return;
                            _submit(l10n);
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
          const SizedBox(width: 24),
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

  Widget _buildMunicipalityDropdown(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.municipalityLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<_MunicipalityOption>(
          value: _selectedMunicipality,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: cs.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
          hint: Text(
            l10n.selectMunicipality,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.outline,
            ),
          ),
          dropdownColor: cs.surface,
          items: const [_staticMunicipality]
              .map(
                (item) => DropdownMenuItem<_MunicipalityOption>(
                  value: item,
                  child: Text(
                    _municipalityLabel(item, l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: _isLoading
              ? null
              : (value) {
                  setState(() => _selectedMunicipality = value);
                },
          validator: (value) {
            if (value == null) {
              return l10n.selectMunicipalityWarning;
            }

            return null;
          },
        ),
      ],
    );
  }
}

class _MunicipalityOption {
  final int id;
  final String nameAr;
  final String nameEn;

  const _MunicipalityOption({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });
}