// lib/features/citizen/home/presentation/widgets/announcements.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/features/citizen/home/data/services/announcement_service.dart';
import 'package:baladiyati/features/citizen/home/data/models/announcement_model.dart';

class AnnouncementsCard extends StatefulWidget {
  const AnnouncementsCard({super.key});

  @override
  State<AnnouncementsCard> createState() => _AnnouncementsCardState();
}

class _AnnouncementsCardState extends State<AnnouncementsCard> {
  final _service = AnnouncementService();
  List<AnnouncementModel> _announcements = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _service.getAnnouncements();
      if (mounted) {
        setState(() {
          _announcements = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception:', '').trim();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.08),
            cs.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Header ──────────────────────────────────────
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
            style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
          ),
          const SizedBox(height: 12),

          // ── Content ──────────────────────────────────────
          if (_loading)
            const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_error != null)
            Text(
              l10n.loadFailed,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.error,
                fontSize: 13,
              ),
            )
          else if (_announcements.isEmpty)
            Text(
              l10n.noAnnouncements,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.outline,
                fontSize: 13,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _announcements.asMap().entries.map((entry) {
                final index = entry.key;
                final a = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      a.title,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.content,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    if (index < _announcements.length - 1)
                      Divider(
                        height: 16,
                        color: cs.primary.withValues(alpha: 0.15),
                      ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
