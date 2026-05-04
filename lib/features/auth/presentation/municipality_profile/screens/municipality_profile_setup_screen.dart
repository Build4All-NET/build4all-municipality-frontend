import 'package:baladiyati/common/widgets/app_text_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/config/app_sizes.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/core/theme/theme_cubit.dart';
import 'package:baladiyati/features/citizen/home/presentation/screens/home_screen.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phone_form_field/phone_form_field.dart';
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

  final _addressCtrl = TextEditingController();
  final Dio _dio = DioClient.muni;

  late final PhoneController _phoneCtrl;

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

    _phoneCtrl = PhoneController(
      initialValue: _initialPhoneNumber(),
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  PhoneNumber _initialPhoneNumber() {
    final phone = (widget.build4allUser['phoneNumber'] ??
            widget.build4allUser['phone'] ??
            '')
        .toString()
        .trim();

    if (phone.isNotEmpty && phone != 'null') {
      try {
        if (phone.startsWith('+')) {
          return PhoneNumber.parse(phone);
        }

        return PhoneNumber.parse('+961$phone');
      } catch (_) {
        return PhoneNumber.parse('+961');
      }
    }

    return PhoneNumber.parse('+961');
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

  String _rawToken() {
    final token = widget.build4allToken.trim();

    if (token.toLowerCase().startsWith('bearer ')) {
      return token.substring(7).trim();
    }

    return token;
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

  String _phoneForBackend() {
    final phone = _phoneCtrl.value;

    final nsn = phone.nsn.trim().replaceAll(RegExp(r'\s+'), '');

    if (nsn.isNotEmpty) return nsn;

    return phone.international.trim().replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _completionPrefsKey() {
    return 'municipality_profile_completed_${widget.ownerProjectLinkId}_${_userId()}';
  }

  /// IMPORTANT:
  /// Do NOT save AuthTokenStore here with refreshToken: null.
  /// LoginScreen already saves AuthTokenStore correctly with refresh token.
  /// Here we only keep JwtStore/Dio fallback updated.
  Future<void> _saveSessionTokenFallbackOnly() async {
    final token = _rawToken();

    if (token.isEmpty) return;

    await JwtStore.save(token);
    DioClient.setAuthToken(token);
  }

  Future<void> _markMunicipalityProfileCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_completionPrefsKey(), true);

    final userId = _userId();

    if (userId > 0) {
      await prefs.setInt('userId', userId);
      await prefs.setString('build4allUserId', userId.toString());
    }

    final token = _rawToken();
    if (token.isNotEmpty) {
      await prefs.setString('build4allToken', token);
    }
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
          code.contains('PROFILE_ALREADY_EXISTS') ||
          message.contains('already') ||
          message.contains('email already') ||
          message.contains('profile already');
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
          'phone': _phoneForBackend(),
          'address': _addressCtrl.text.trim(),
          'role': 'USER',
          'municipality': {
            'id': selectedMunicipality.id,
          },
        },
      );

      await _saveSessionTokenFallbackOnly();
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
        await _saveSessionTokenFallbackOnly();
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
                        _buildPhoneField(context, l10n),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _addressCtrl,
                          label: l10n.addressLabel,
                          hint: l10n.addressHint,
                          icon: Icons.location_on_outlined,
                          textAlign: TextAlign.left,
                          validator: (v) {
                            final value = v?.trim() ?? '';

                            if (value.isEmpty) return l10n.fieldRequired;
                            if (value.length < 6) return l10n.addressTooShort;

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

  Widget _buildPhoneField(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: PhoneFormField(
        controller: _phoneCtrl,
        enabled: !_isLoading,
        countrySelectorNavigator: const CountrySelectorNavigator.dialog(),
        decoration: InputDecoration(
          labelText: l10n.phoneLabel,
          hintText: l10n.phoneHint,
          prefixIcon: const Icon(Icons.phone_outlined),
          filled: true,
          fillColor: cs.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            borderSide: BorderSide(
              color: cs.outline.withOpacity(0.35),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            borderSide: BorderSide(
              color: cs.primary,
              width: 2,
            ),
          ),
        ),
        validator: PhoneValidator.compose([
          PhoneValidator.required(
            context,
            errorText: l10n.fieldRequired,
          ),
          PhoneValidator.validMobile(
            context,
            errorText: l10n.phoneInvalid,
          ),
        ]),
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
            if (value == null) return l10n.selectMunicipalityWarning;
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