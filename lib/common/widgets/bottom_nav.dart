// lib/common/widgets/bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

/// One citizen navigation destination, shared by [BottomNav] (phones)
/// and [SideNav] (web / desktop) so both always show the same items.
class AppNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

List<AppNavItem> citizenNavItems(AppLocalizations l10n) => [
      AppNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: l10n.navHome),
      AppNavItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: l10n.navServices),
      AppNavItem(icon: Icons.description_outlined, activeIcon: Icons.description, label: l10n.navRequests),
      AppNavItem(icon: Icons.credit_card_outlined, activeIcon: Icons.credit_card, label: l10n.navPayments),
      AppNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: l10n.navAccount),
    ];

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
    final cs = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,

      // Dynamic colors from THEME_JSON_B64.
      backgroundColor: cs.surface,
      selectedItemColor: cs.primary,
      unselectedItemColor: cs.outline,

      selectedFontSize: 11,
      unselectedFontSize: 11,

      items: [
        for (final item in citizenNavItems(l10n))
          BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.activeIcon),
            label: item.label,
          ),
      ],
    );
  }
}
