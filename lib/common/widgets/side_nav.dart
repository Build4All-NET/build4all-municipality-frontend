// lib/common/widgets/side_nav.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

import 'app_sidebar.dart';
import 'bottom_nav.dart';

/// Citizen navigation on web / tablet, used instead of [BottomNav].
/// Shows icons only on tablets and icons + labels when [extended].
class SideNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool extended;

  /// Municipality name shown under the app name.
  final String? municipalityName;

  /// Signed-in citizen, shown in the sidebar footer.
  final String? userName;

  const SideNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.extended = false,
    this.municipalityName,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppSidebar(
      title: l10n.appTitle,
      subtitle: municipalityName ?? l10n.appSubtitle,
      collapsed: !extended,
      selectedIndex: currentIndex,
      onSelected: onTap,
      userName: userName,
      userRole: userName == null ? null : l10n.citizen,
      items: [
        for (final item in citizenNavItems(l10n))
          SidebarItem(icon: item.icon, selectedIcon: item.activeIcon, label: item.label),
      ],
    );
  }
}
