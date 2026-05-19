import 'package:flutter/material.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/features/citizen/services/domain/entities/service_entity.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'new_request_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceEntity service;
  const ServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(loc.serviceDetails)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + name card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outline.withOpacity(0.12)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.description_outlined,
                        color: colors.primary, size: 32),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    service.localizedName(langCode),
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.localizedDescription(langCode),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colors.outline),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outline.withOpacity(0.12)),
              ),
              child: Column(
                children: [
                  if (service.slaDays != null)
                    _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: loc.slaDays,
                      value: '${service.slaDays} ${loc.days}',
                      theme: theme,
                      colors: colors,
                    ),
                  if (service.hasFees && service.feeAmount != null) ...[
                    if (service.slaDays != null) const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.attach_money,
                      label: loc.feeLabel,
                      value: service.feeAmount!.toStringAsFixed(0),
                      theme: theme,
                      colors: colors,
                    ),
                  ],
                  if (service.requiresInspection) ...[
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.search_outlined,
                      label: loc.requiresInspection,
                      value: loc.active,
                      theme: theme,
                      colors: colors,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            PrimaryButton(
              label: loc.startRequest,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewRequestScreen(service: service),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme colors;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: 12),
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colors.outline)),
        const Spacer(),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
