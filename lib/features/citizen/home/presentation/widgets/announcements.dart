// lib/features/citizen/home/presentation/widgets/announcements.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class AnnouncementsCard extends StatelessWidget {
  const AnnouncementsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.municipalAnnouncements,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.latestNews,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.workingHours,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
