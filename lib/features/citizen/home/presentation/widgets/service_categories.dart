// lib/features/citizen/home/presentation/widgets/service_categories.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class ServiceCategoryItem {
  final String nameAr;
  final String nameEn;
  final IconData icon;
  final Color color;

  const ServiceCategoryItem({
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.color,
  });
}

final List<ServiceCategoryItem> serviceCategories = [
  ServiceCategoryItem(
    nameAr: 'الخدمات العامة',
    nameEn: 'General Services',
    icon: Icons.description_outlined,
    color: const Color(0xFF3B82F6),
  ),
  ServiceCategoryItem(
    nameAr: 'الخدمات التجارية والمهنية',
    nameEn: 'Commercial Services',
    icon: Icons.storefront_outlined,
    color: const Color(0xFFF59E0B),
  ),
  ServiceCategoryItem(
    nameAr: 'الخدمات العقارية',
    nameEn: 'Real Estate',
    icon: Icons.apartment_outlined,
    color: const Color(0xFF8B5CF6),
  ),
  ServiceCategoryItem(
    nameAr: 'الخدمات الهندسية',
    nameEn: 'Engineering',
    icon: Icons.engineering_outlined,
    color: const Color(0xFF10B981),
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

    return Column(
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                l10n.viewAll,
                style: const TextStyle(
                    color: Color(0xFF2F6FED),
                    fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              l10n.serviceCategories,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Grid
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
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
                        color: category.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(category.icon,
                          color: category.color, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.nameAr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
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
