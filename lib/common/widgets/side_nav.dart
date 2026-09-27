// lib/common/widgets/side_nav.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/core/config/app_breakpoints.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

import 'bottom_nav.dart';

/// Side navigation used instead of [BottomNav] on web / desktop.
/// Shows icons only on medium screens and icons + labels when [extended].
class SideNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended;

  const SideNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      extended: extended,
      minExtendedWidth: AppLayout.railExtendedWidth,
      labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,

      // Dynamic colors from THEME_JSON_B64, same as the bottom bar.
      backgroundColor: cs.surface,
      indicatorColor: cs.primary.withOpacity(0.12),
      selectedIconTheme: IconThemeData(color: cs.primary),
      unselectedIconTheme: IconThemeData(color: cs.outline),
      selectedLabelTextStyle: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: cs.outline),

      destinations: [
        for (final item in citizenNavItems(l10n))
          NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.activeIcon),
            label: Text(item.label),
          ),
      ],
    );
  }
}
