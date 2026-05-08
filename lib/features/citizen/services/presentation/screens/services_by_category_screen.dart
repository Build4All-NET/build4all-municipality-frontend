import 'package:baladiyati/common/widgets/app_text_field.dart';
import 'package:baladiyati/core/config/app_sizes.dart';
import 'package:baladiyati/features/citizen/services/domain/entities/citizen_service_entity.dart';
import 'package:baladiyati/features/citizen/services/presentation/screens/new_request_screen.dart';
import 'package:baladiyati/features/citizen/services/presentation/widgets/citizen_service_card.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ServicesByCategoryScreen extends StatefulWidget {
  final String categoryTitle;
  final IconData categoryIcon;
  final List<CitizenServiceEntity> services;

  const ServicesByCategoryScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.services,
  });

  @override
  State<ServicesByCategoryScreen> createState() =>
      _ServicesByCategoryScreenState();
}

class _ServicesByCategoryScreenState extends State<ServicesByCategoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CitizenServiceEntity> get _filteredServices {
    final text = _query.trim().toLowerCase();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (text.isEmpty) return widget.services;

    return widget.services.where((service) {
      final name = service.localizedName(isArabic: isArabic).toLowerCase();
      final description =
          service.localizedDescription(isArabic: isArabic).toLowerCase();

      return name.contains(text) || description.contains(text);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: cs.surface,
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_forward,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingSmall),
                      Container(
                        width: AppSizes.iconLarge * 0.60,
                        height: AppSizes.iconLarge * 0.60,
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                        child: Icon(
                          widget.categoryIcon,
                          color: cs.primary,
                          size: AppSizes.iconMedium,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.categoryTitle,
                              textAlign: TextAlign.right,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: AppSizes.paddingSmall / 2),
                            Text(
                              '${_filteredServices.length} ${l10n.serviceCount}',
                              textAlign: TextAlign.right,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  AppTextField(
                    controller: _searchController,
                    label: l10n.searchInServices,
                    hint: l10n.searchInServices,
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
              child: _filteredServices.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noServices,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      itemCount: _filteredServices.length,
                      separatorBuilder: (_, __) {
                        return const SizedBox(height: AppSizes.paddingSmall);
                      },
                      itemBuilder: (context, index) {
                        final service = _filteredServices[index];

                        return CitizenServiceCard(
                          service: service,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NewRequestScreen(
                                  service: service,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}