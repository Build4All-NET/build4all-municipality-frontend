// lib/features/citizen/home/presentation/widgets/announcements.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class AnnouncementsCard extends StatelessWidget {
  const AnnouncementsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Soft card using dynamic primary color.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.08),
            cs.primary.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.primary.withOpacity(0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.municipalAnnouncements,
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            l10n.latestNews,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.outline,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            l10n.workingHours,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}