// lib/features/citizen/home/presentation/widgets/quick_actions.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onNewRequest;
  final VoidCallback onPayments;

  const QuickActions({
    super.key,
    required this.onNewRequest,
    required this.onPayments,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.quickActions,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Payments button
              Expanded(
                child: _ActionButton(
                  icon: Icons.error_outline,
                  iconColor: Colors.orange,
                  label: l10n.navPayments,
                  onTap: onPayments,
                ),
              ),
              const SizedBox(width: 12),
              // New Request button
              Expanded(
                child: _ActionButton(
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF1E3A5F),
                  label: l10n.newRequest,
                  onTap: onNewRequest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
