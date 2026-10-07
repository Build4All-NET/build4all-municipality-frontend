// lib/common/widgets/app_sidebar.dart

import 'package:baladiyati/core/config/app_branding.dart';
import 'package:flutter/material.dart';
import 'package:baladiyati/core/config/app_breakpoints.dart';
import 'package:baladiyati/core/config/app_sizes.dart';

/// One entry in [AppSidebar].
class SidebarItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const SidebarItem({required this.icon, required this.label, this.selectedIcon});
}

/// A secondary action in the sidebar footer (profile, language, logout...).
class SidebarAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const SidebarAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
}

/// Web / tablet navigation panel shared by the citizen, owner and staff apps:
/// brand header, navigation items, and a footer with the signed-in user and
/// account actions. [collapsed] shows icons only (tablet widths).
class AppSidebar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData brandIcon;
  final List<SidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String? userName;
  final String? userRole;
  final List<SidebarAction> actions;
  final bool collapsed;

  const AppSidebar({
    super.key,
    required this.title,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.subtitle,
    this.brandIcon = Icons.apartment_rounded,
    this.userName,
    this.userRole,
    this.actions = const [],
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      child: Container(
        width: collapsed ? AppLayout.sidebarCollapsedWidth : AppLayout.sidebarWidth,
        decoration: BoxDecoration(
          border: BorderDirectional(
            end: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Brand(title: title, subtitle: subtitle, icon: brandIcon, collapsed: collapsed),
              const SizedBox(height: AppSizes.paddingSmall),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSmall + 4,
                    vertical: AppSizes.paddingSmall,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, i) => _NavTile(
                    item: items[i],
                    selected: i == selectedIndex,
                    collapsed: collapsed,
                    onTap: () => onSelected(i),
                  ),
                ),
              ),
              if (userName != null || actions.isNotEmpty)
                _Footer(
                  userName: userName,
                  userRole: userRole,
                  actions: actions,
                  collapsed: collapsed,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool collapsed;

  const _Brand({required this.title, required this.icon, required this.collapsed, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final logo = BrandLogo(
      size: AppLayout.sidebarLogoSize,
      radius: AppSizes.radiusMedium,
      fallback: Container(
        width: AppLayout.sidebarLogoSize,
        height: AppLayout.sidebarLogoSize,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Icon(icon, color: cs.onPrimary, size: AppSizes.iconMedium),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        AppSizes.paddingLarge,
        AppSizes.paddingMedium,
        AppSizes.paddingSmall,
      ),
      child: collapsed
          ? Center(child: Tooltip(message: title, child: logo))
          : Row(
              children: [
                logo,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final SidebarItem item;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = selected ? cs.primary : cs.onSurfaceVariant;

    final tile = Material(
      color: selected ? cs.primary.withOpacity(0.10) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium - 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium - 2),
        hoverColor: cs.primary.withOpacity(0.05),
        child: SizedBox(
          height: AppLayout.sidebarItemHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(selected ? (item.selectedIcon ?? item.icon) : item.icon, color: fg, size: 22),
                if (!collapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: fg,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return collapsed ? Tooltip(message: item.label, child: tile) : tile;
  }
}

class _Footer extends StatelessWidget {
  final String? userName;
  final String? userRole;
  final List<SidebarAction> actions;
  final bool collapsed;

  const _Footer({required this.actions, required this.collapsed, this.userName, this.userRole});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final name = (userName ?? '').trim();

    final avatar = CircleAvatar(
      radius: 18,
      backgroundColor: cs.primary.withOpacity(0.12),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: theme.textTheme.titleSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w800),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall + 4),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outlineVariant.withOpacity(0.6))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (userName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
              child: collapsed
                  ? Center(child: Tooltip(message: name, child: avatar))
                  : Row(
                      children: [
                        avatar,
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.isEmpty ? '...' : name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (userRole != null)
                                Text(
                                  userRole!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          if (collapsed)
            for (final a in actions)
              IconButton(
                tooltip: a.label,
                onPressed: a.onTap,
                icon: Icon(a.icon, color: a.destructive ? cs.error : cs.onSurfaceVariant),
              )
          else
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final a in actions)
                  TextButton.icon(
                    onPressed: a.onTap,
                    icon: Icon(a.icon, size: 18),
                    label: Text(a.label),
                    style: TextButton.styleFrom(
                      foregroundColor: a.destructive ? cs.error : cs.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
