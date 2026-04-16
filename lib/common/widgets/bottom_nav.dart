// lib/common/widgets/bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E3A5F),
      unselectedItemColor: Colors.grey,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: l10n.navHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.grid_view_outlined),
          activeIcon: const Icon(Icons.grid_view),
          label: l10n.navServices,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.description_outlined),
          activeIcon: const Icon(Icons.description),
          label: l10n.navRequests,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.credit_card_outlined),
          activeIcon: const Icon(Icons.credit_card),
          label: l10n.navPayments,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: l10n.navAccount,
        ),
      ],
    );
  }
}
