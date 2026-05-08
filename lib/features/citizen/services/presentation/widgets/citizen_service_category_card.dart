import 'package:baladiyati/core/config/app_sizes.dart';
import 'package:flutter/material.dart';

class CitizenServiceCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const CitizenServiceCategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(
          color: cs.outline.withOpacity(0.12),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Row(
            children: [
              Icon(
                Icons.arrow_back_ios_new,
                size: AppSizes.iconSmall,
                color: cs.onSurfaceVariant,
              ),
              const Spacer(),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall / 2),
                    Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Container(
                width: AppSizes.iconLarge * 0.65,
                height: AppSizes.iconLarge * 0.65,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Icon(
                  icon,
                  color: cs.primary,
                  size: AppSizes.iconMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}