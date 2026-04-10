import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/features/auth/presentation/login/screens/login_screen.dart';
import '../bloc/complete_profile_bloc.dart';
import '../bloc/complete_profile_event.dart';
import '../bloc/complete_profile_state.dart';
import '../../../data/services/auth_api_service.dart';
import '../../../../../../core/config/app_colors.dart';
import '../../../../../../core/config/app_sizes.dart';
import '../../../../../../common/widgets/primary_button.dart';

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
  State<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

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

  void _onSubmit(BuildContext context, AppLocalizations l10n) {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMunicipality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectMunicipalityWarning),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<CompleteProfileBloc>().add(
          CompleteProfileSubmitted(
            username: _usernameCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            //municipalityId: _selectedMunicipality!.id, // 
          ),
        );
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
      child: Builder(builder: (context) {
        return BlocConsumer<CompleteProfileBloc, CompleteProfileState>(
          listener: (context, state) {
            final l10n = AppLocalizations.of(context)!;

            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.completeProfileSuccess),
                  backgroundColor: Colors.green,
                ),
              );

              Future.delayed(const Duration(milliseconds: 500), () {
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (_) => false,
                );
              });
            }

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
            final l10n = AppLocalizations.of(context)!;

            return Scaffold(
              backgroundColor: AppColors.background,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              )
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
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // USERNAME
                                _label(l10n.usernameLabel),
                                const SizedBox(height: 8),
                                _textField(
                                  controller: _usernameCtrl,
                                  hint: l10n.usernameHint,
                                  icon: Icons.person_outline,
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

                                // ADDRESS ✅ UPDATED
                                _label(l10n.addressLabel),
                                const SizedBox(height: 8),
                                _textField(
                                  controller: _addressCtrl,
                                  hint: 'Lebanon, Beirut, Building 5, Main Street',
                                  icon: Icons.location_on_outlined,
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

                                    final parts = value.split(',');
                                    if (parts.length < 4) {
                                      return 'Format: Country, City, Building, Street';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // MUNICIPALITY
                                _label(l10n.municipalityLabel),
                                const SizedBox(height: 8),
                                _municipalityDropdown(l10n),

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
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
            child: const Icon(Icons.arrow_back_ios_new),
          ),
          Text(l10n.appTitle),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text);

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  Widget _municipalityDropdown(AppLocalizations l10n) {
    return DropdownButton<_Municipality>(
      value: _selectedMunicipality,
      hint: Text(l10n.selectMunicipality),
      items: _municipalities
          .map((m) => DropdownMenuItem(
                value: m,
                child: Text(_getMunicipalityName(m, l10n)),
              ))
          .toList(),
      onChanged: (val) => setState(() => _selectedMunicipality = val),
    );
  }
}