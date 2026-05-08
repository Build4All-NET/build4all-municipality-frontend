import 'package:baladiyati/common/widgets/app_text_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/config/app_sizes.dart';
import 'package:baladiyati/features/citizen/services/domain/entities/citizen_service_entity.dart';
import 'package:baladiyati/features/citizen/services/presentation/bloc/citizen_services_bloc.dart';
import 'package:baladiyati/features/citizen/services/presentation/bloc/citizen_services_event.dart';
import 'package:baladiyati/features/citizen/services/presentation/bloc/citizen_services_state.dart';
import 'package:baladiyati/features/citizen/services/presentation/screens/services_by_category_screen.dart';
import 'package:baladiyati/features/citizen/services/presentation/widgets/citizen_service_category_card.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _CitizenServiceCategory {
  final int departmentId;
  final String title;
  final IconData icon;
  final List<CitizenServiceEntity> services;

  const _CitizenServiceCategory({
    required this.departmentId,
    required this.title,
    required this.icon,
    required this.services,
  });
}

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_CitizenServiceCategory> _buildCategories(
    BuildContext context,
    List<CitizenServiceEntity> services,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final grouped = <int, List<CitizenServiceEntity>>{};

    for (final service in services) {
      final departmentId = service.departmentId ?? 0;
      grouped.putIfAbsent(departmentId, () => []);
      grouped[departmentId]!.add(service);
    }

    final categories = grouped.entries.map((entry) {
      final departmentId = entry.key;

      return _CitizenServiceCategory(
        departmentId: departmentId,
        title: departmentId == 0
            ? l10n.municipalServices
            : '${l10n.municipalServices} $departmentId',
        icon: _iconForDepartment(departmentId),
        services: entry.value,
      );
    }).toList();

    categories.sort((a, b) => a.departmentId.compareTo(b.departmentId));

    return categories;
  }

  List<_CitizenServiceCategory> _filterCategories(
    BuildContext context,
    List<_CitizenServiceCategory> categories,
  ) {
    final text = _query.trim().toLowerCase();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (text.isEmpty) return categories;

    return categories.where((category) {
      final categoryMatch = category.title.toLowerCase().contains(text);

      final serviceMatch = category.services.any((service) {
        final name = service.localizedName(isArabic: isArabic).toLowerCase();
        final description =
            service.localizedDescription(isArabic: isArabic).toLowerCase();

        return name.contains(text) || description.contains(text);
      });

      return categoryMatch || serviceMatch;
    }).toList();
  }

  IconData _iconForDepartment(int departmentId) {
    final icons = <IconData>[
      Icons.description_outlined,
      Icons.apartment_outlined,
      Icons.engineering_outlined,
      Icons.storefront_outlined,
      Icons.shield_outlined,
      Icons.payments_outlined,
      Icons.construction_outlined,
    ];

    return icons[departmentId.abs() % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CitizenServicesBloc()
        ..add(
          const LoadCitizenServicesEvent(),
        ),
      child: const _ServicesScreenView(),
    );
  }
}

class _ServicesScreenView extends StatefulWidget {
  const _ServicesScreenView();

  @override
  State<_ServicesScreenView> createState() => _ServicesScreenViewState();
}

class _ServicesScreenViewState extends State<_ServicesScreenView> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_CitizenServiceCategory> _buildCategories(
    BuildContext context,
    List<CitizenServiceEntity> services,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final grouped = <int, List<CitizenServiceEntity>>{};

    for (final service in services) {
      final departmentId = service.departmentId ?? 0;
      grouped.putIfAbsent(departmentId, () => []);
      grouped[departmentId]!.add(service);
    }

    final categories = grouped.entries.map((entry) {
      final departmentId = entry.key;

      return _CitizenServiceCategory(
        departmentId: departmentId,
        title: departmentId == 0
            ? l10n.municipalServices
            : '${l10n.municipalServices} $departmentId',
        icon: _iconForDepartment(departmentId),
        services: entry.value,
      );
    }).toList();

    categories.sort((a, b) => a.departmentId.compareTo(b.departmentId));

    return categories;
  }

  List<_CitizenServiceCategory> _filterCategories(
    BuildContext context,
    List<_CitizenServiceCategory> categories,
  ) {
    final text = _query.trim().toLowerCase();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (text.isEmpty) return categories;

    return categories.where((category) {
      final categoryMatch = category.title.toLowerCase().contains(text);

      final serviceMatch = category.services.any((service) {
        final name = service.localizedName(isArabic: isArabic).toLowerCase();
        final description =
            service.localizedDescription(isArabic: isArabic).toLowerCase();

        return name.contains(text) || description.contains(text);
      });

      return categoryMatch || serviceMatch;
    }).toList();
  }

  IconData _iconForDepartment(int departmentId) {
    final icons = <IconData>[
      Icons.description_outlined,
      Icons.apartment_outlined,
      Icons.engineering_outlined,
      Icons.storefront_outlined,
      Icons.shield_outlined,
      Icons.payments_outlined,
      Icons.construction_outlined,
    ];

    return icons[departmentId.abs() % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: BlocConsumer<CitizenServicesBloc, CitizenServicesState>(
          listener: (context, state) {
            if (state.status == CitizenServicesStatus.failure &&
                state.errorMessage != null) {
              AppToast.show(
                context,
                message: state.errorMessage!,
                type: AppToastType.error,
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  color: cs.surface,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.municipalServices,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      AppTextField(
                        controller: _searchController,
                        label: l10n.searchService,
                        hint: l10n.searchService,
                        icon: Icons.search,
                        textAlign: TextAlign.right,
                        onChanged: (value) {
                          setState(() => _query = value);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CitizenServicesState state,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (state.status == CitizenServicesStatus.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: cs.primary,
        ),
      );
    }

    if (state.status == CitizenServicesStatus.failure) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: cs.error,
              size: AppSizes.iconLarge * 0.65,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              state.errorMessage ?? l10n.errorGeneric,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            PrimaryButton(
              label: l10n.errorGeneric,
              onPressed: () {
                context.read<CitizenServicesBloc>().add(
                      const LoadCitizenServicesEvent(),
                    );
              },
            ),
          ],
        ),
      );
    }

    final categories = _filterCategories(
      context,
      _buildCategories(context, state.services),
    );

    if (categories.isEmpty) {
      return Center(
        child: Text(
          l10n.noServices,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () async {
        context.read<CitizenServicesBloc>().add(
              const RefreshCitizenServicesEvent(),
            );
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) {
          return const SizedBox(height: AppSizes.paddingSmall);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: AppSizes.paddingSmall,
              ),
              child: Text(
                l10n.selectCategory,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            );
          }

          final category = categories[index - 1];

          return CitizenServiceCategoryCard(
            title: category.title,
            subtitle: '${category.services.length} ${l10n.serviceCount}',
            icon: category.icon,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServicesByCategoryScreen(
                    categoryTitle: category.title,
                    categoryIcon: category.icon,
                    services: category.services,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}