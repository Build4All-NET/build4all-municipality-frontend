// lib/features/citizen/home/presentation/widgets/service_categories.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class ServiceCategoryItem {
  final String nameAr;
  final String nameEn;
  final IconData icon;

  const ServiceCategoryItem({
    required this.nameAr,
    required this.nameEn,
    required this.icon,
  });
}

final List<ServiceCategoryItem> serviceCategories = [
  const ServiceCategoryItem(
    nameAr: 'الخدمات العامة',
    nameEn: 'General Services',
    icon: Icons.description_outlined,
  ),
  const ServiceCategoryItem(
    nameAr: 'الخدمات التجارية والمهنية',
    nameEn: 'Commercial Services',
    icon: Icons.storefront_outlined,
  ),
  const ServiceCategoryItem(
    nameAr: 'الخدمات العقارية',
    nameEn: 'Real Estate',
    icon: Icons.apartment_outlined,
  ),
  const ServiceCategoryItem(
    nameAr: 'الخدمات الهندسية',
    nameEn: 'Engineering',
    icon: Icons.engineering_outlined,
  ),
];

class ServiceCategoriesSection extends StatelessWidget {
  final VoidCallback onViewAll;
  final Function(ServiceCategoryItem) onCategoryTap;

  const ServiceCategoriesSection({
    super.key,
    required this.onViewAll,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        // Section header.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                l10n.viewAll,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              l10n.serviceCategories,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: serviceCategories.map((category) {
            return GestureDetector(
              onTap: () => onCategoryTap(category),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cs.onSurface.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category.icon,
                        color: cs.primary,
                        size: 24,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      category.nameAr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}