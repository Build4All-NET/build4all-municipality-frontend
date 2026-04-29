import 'dart:convert';

import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/common/registration_step_cubit.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/auth/data/services/api_auth_build4all_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/features/auth/presentation/login/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/complete_profile_bloc.dart';
import '../bloc/complete_profile_event.dart';
import '../bloc/complete_profile_state.dart';
import '../../../data/services/auth_api_service.dart';
import '../../../../../../core/config/app_sizes.dart';
import '../../../../../../common/widgets/primary_button.dart';
import '../../../../../../common/widgets/app_toast.dart';
import '../../../../../../common/widgets/app_text_field.dart';

class _Municipality {
  final int id;
  final String nameAr;
  final String nameEn;
  final String nameFr;

  const _Municipality({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nameFr,
  });
}

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _authApi = AuthApi(DioClient.build);

  final List<_Municipality> _municipalities = const [
    _Municipality(id: 1, nameAr: 'بلدية بيروت', nameEn: 'Beirut', nameFr: 'Beyrouth'),
    _Municipality(id: 2, nameAr: 'بلدية طرابلس', nameEn: 'Tripoli', nameFr: 'Tripoli'),
    _Municipality(id: 3, nameAr: 'بلدية صيدا', nameEn: 'Sidon', nameFr: 'Saïda'),
    _Municipality(id: 4, nameAr: 'بلدية صور', nameEn: 'Tyre', nameFr: 'Tyr'),
    _Municipality(id: 5, nameAr: 'بلدية زحلة', nameEn: 'Zahle', nameFr: 'Zahlé'),
    _Municipality(id: 6, nameAr: 'بلدية جونية', nameEn: 'Jounieh', nameFr: 'Jounieh'),
    _Municipality(id: 7, nameAr: 'بلدية بعلبك', nameEn: 'Baalbek', nameFr: 'Baalbek'),
    _Municipality(id: 8, nameAr: 'بلدية النبطية', nameEn: 'Nabatieh', nameFr: 'Nabatiyé'),
  ];

  _Municipality? _selectedMunicipality;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('register_body');
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> _onSubmit(BuildContext context, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMunicipality == null) {
      AppToast.show(
        context,
        message: l10n.selectMunicipalityWarning,
        type: AppToastType.error,
      );
      return;
    }

    try {
      final body = await _getFromPrefs();

      if (body == null) {
        AppToast.show(
          context,
          message: 'No saved registration data found',
          type: AppToastType.error,
        );
        return;
      }

      await _authApi.ownerCompleteProfile(
        pendingId: body['userId'].toString(),
        firstName: body['fullName'],
        lastName: body['lastname'],
        username: _usernameCtrl.text.trim(),
        isPublicProfile: false,
        ownerProjectLinkId: body['ownerProjectLinkId'].toString(),
      );

      if (!context.mounted) return;

      context.read<CompleteProfileBloc>().add(
            CompleteProfileSubmitted(
              username: _usernameCtrl.text.trim(),
              address: _addressCtrl.text.trim(),
            ),
          );

      context.read<RegistrationStepCubit>().nextStep();

      AppRouter.goToWelcome(context);
    } catch (e) {
      if (!context.mounted) return;

      AppToast.show(
        context,
        message: 'Error: $e',
        type: AppToastType.error,
      );
    }
  }

  String _getMunicipalityName(_Municipality m, AppLocalizations l10n) {
    if (l10n.localeName == 'ar') return m.nameAr;
    if (l10n.localeName == 'fr') return m.nameFr;
    return m.nameEn;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CompleteProfileBloc(authApi: AuthApiService()),
      child: Builder(
        builder: (context) {
          return BlocConsumer<CompleteProfileBloc, CompleteProfileState>(
            listener: (context, state) {
              final l10n = AppLocalizations.of(context)!;

              if (state.isSuccess) {
                AppToast.show(
                  context,
                  message: l10n.completeProfileSuccess,
                  type: AppToastType.success,
                );

                Future.delayed(const Duration(milliseconds: 500), () {
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                });
              }

              if (state.errorMessage != null) {
                AppToast.show(
                  context,
                  message: state.errorMessage!,
                  type: AppToastType.error,
                );
              }
            },
            builder: (context, state) {
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

                                  const SizedBox(height: 28),

                                  AppTextField(
                                    controller: _usernameCtrl,
                                    label: l10n.usernameLabel,
                                    hint: l10n.usernameHint,
                                    icon: Icons.person_outline,
                                    textAlign: TextAlign.right,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return l10n.fieldRequired;
                                      }
                                      if (v.trim().length < 3) {
                                        return l10n.usernameTooShort;
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  AppTextField(
                                    controller: _addressCtrl,
                                    label: l10n.addressLabel,
                                    hint: 'Lebanon, Beirut, Building 5, Main Street',
                                    icon: Icons.location_on_outlined,
                                    textAlign: TextAlign.right,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return l10n.fieldRequired;
                                      }

                                      final value = v.trim();

                                      if (value.length < 10) {
                                        return 'Address is too short';
                                      }

                                      if (!RegExp(r'^[a-zA-Z0-9 ,.\-]+$').hasMatch(value)) {
                                        return 'Use only English letters, numbers, commas and dots';
                                      }

                                      if (value.split(',').length < 4) {
                                        return 'Format: Country, City, Building, Street';
                                      }

                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  _municipalityDropdown(context, l10n),

                                  const SizedBox(height: 28),

                                  PrimaryButton(
                                    label: l10n.completeProfileButton,
                                    isLoading: state.isLoading,
                                    onPressed: () => _onSubmit(context, l10n),
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
            },
          );
        },
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
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_new, color: cs.onSurface),
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

  Widget _municipalityDropdown(BuildContext context, AppLocalizations l10n) {
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
        DropdownButtonFormField<_Municipality>(
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
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.outline),
          ),
          dropdownColor: cs.surface,
          items: _municipalities
              .map(
                (m) => DropdownMenuItem(
                  value: m,
                  child: Text(
                    _getMunicipalityName(m, l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedMunicipality = val),
          validator: (val) {
            if (val == null) return l10n.selectMunicipalityWarning;
            return null;
          },
        ),
      ],
    );
  }
}