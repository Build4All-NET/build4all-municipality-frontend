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
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  final List<_Municipality> _municipalities = const [
    _Municipality(id: 1, nameAr: 'بلدية بيروت',   nameEn: 'Beirut',    nameFr: 'Beyrouth'),
    _Municipality(id: 2, nameAr: 'بلدية طرابلس',  nameEn: 'Tripoli',   nameFr: 'Tripoli'),
    _Municipality(id: 3, nameAr: 'بلدية صيدا',    nameEn: 'Sidon',     nameFr: 'Saïda'),
    _Municipality(id: 4, nameAr: 'بلدية صور',     nameEn: 'Tyre',      nameFr: 'Tyr'),
    _Municipality(id: 5, nameAr: 'بلدية زحلة',    nameEn: 'Zahle',     nameFr: 'Zahlé'),
    _Municipality(id: 6, nameAr: 'بلدية جونية',   nameEn: 'Jounieh',   nameFr: 'Jounieh'),
    _Municipality(id: 7, nameAr: 'بلدية بعلبك',   nameEn: 'Baalbek',   nameFr: 'Baalbek'),
    _Municipality(id: 8, nameAr: 'بلدية النبطية', nameEn: 'Nabatieh',  nameFr: 'Nabatiyé'),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.selectMunicipalityWarning),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    context.read<CompleteProfileBloc>().add(CompleteProfileSubmitted(
      username: _usernameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    ));
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.completeProfileSuccess),
                backgroundColor: Colors.green,
              ));
              // Navigate to LoginScreen after profile completion
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ));
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
                        padding:
                            const EdgeInsets.all(AppSizes.paddingLarge),
                        child: Container(
                          padding:
                              const EdgeInsets.all(AppSizes.paddingLarge),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusLarge),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Center(
                                    child: Text(l10n.completeProfileTitle,
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkBlue))),
                                const SizedBox(height: 6),
                                Center(
                                    child: Text(l10n.completeProfileSubtitle,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey))),
                                const SizedBox(height: 28),
                                _label(l10n.usernameLabel),
                                const SizedBox(height: 8),
                                _textField(
                                  controller: _usernameCtrl,
                                  hint: l10n.usernameHint,
                                  icon: Icons.person_outline,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return l10n.fieldRequired;
                                    if (v.trim().length < 3)
                                      return l10n.usernameTooShort;
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _label(l10n.addressLabel),
                                const SizedBox(height: 8),
                                _textField(
                                  controller: _addressCtrl,
                                  hint: l10n.addressHint,
                                  icon: Icons.location_on_outlined,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? l10n.fieldRequired
                                          : null,
                                ),
                                const SizedBox(height: 16),
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
          vertical: AppSizes.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: AppColors.primary),
            ),
          ),
          Row(children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.appTitle,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  Text(l10n.appSubtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                ]),
            const SizedBox(width: 10),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.apartment,
                  color: Colors.white, size: 24),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkBlue));

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
      ),
      validator: validator,
    );
  }

  Widget _municipalityDropdown(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedMunicipality != null
              ? AppColors.primary
              : Colors.grey.shade200,
          width: _selectedMunicipality != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_Municipality>(
          value: _selectedMunicipality,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.primary),
          hint: Align(
            alignment: Alignment.centerRight,
            child: Text(l10n.selectMunicipality,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: _municipalities
              .map((m) => DropdownMenuItem<_Municipality>(
                    value: m,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(_getMunicipalityName(m, l10n),
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.darkBlue)),
                    ),
                  ))
              .toList(),
          onChanged: (val) =>
              setState(() => _selectedMunicipality = val),
        ),
      ),
    );
  }
}