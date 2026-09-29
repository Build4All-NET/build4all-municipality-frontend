import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/core/l10n/locale_cubit.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/auth_token_store.dart';
import 'package:baladiyati/features/auth/data/services/session_role_store.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/common/widgets/app_sidebar.dart';
import 'package:baladiyati/common/widgets/responsive_center.dart';
import 'package:baladiyati/core/config/app_breakpoints.dart';
import 'package:baladiyati/core/utils/responsive.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      try {
        await DioClient.build.post('/auth/logout');
      } catch (_) {
        // Even if logout API fails, clear local session.
      }

      await const AdminTokenStore().clear();
      await AuthTokenStore().clear();
      await SessionRoleStore().clearRole();
      await JwtStore.clear();

      DioClient.clearAuthToken();

      if (!mounted) return;

      AppRouter.goToLogin(context);
    } catch (e) {
      if (!mounted) return;

      AppToast.show(
        context,
        message: e.toString().replaceAll('Exception:', '').trim(),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  void _showLanguageSheet() {
    final loc = AppLocalizations.of(context)!;
    final localeCubit = context.read<LocaleCubit>();
    final currentCode = localeCubit.currentLanguageCode;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colors = theme.colorScheme;

        Widget languageTile({
          required String code,
          required String title,
          required String subtitle,
          required VoidCallback onTap,
        }) {
          final selected = currentCode == code;

          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: CircleAvatar(
              backgroundColor: selected
                  ? colors.primary.withOpacity(0.14)
                  : colors.surfaceContainerHighest,
              child: Text(
                code.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected ? colors.primary : colors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: selected
                ? Icon(
                    Icons.check_circle,
                    color: colors.primary,
                  )
                : null,
            onTap: () {
              onTap();
              Navigator.pop(sheetContext);
            },
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.selectLanguage,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                languageTile(
                  code: 'ar',
                  title: 'العربية',
                  subtitle: AppLocalizations.of(context)!.languageArabic,
                  onTap: localeCubit.setArabic,
                ),
                languageTile(
                  code: 'en',
                  title: 'English',
                  subtitle: AppLocalizations.of(context)!.languageEnglish,
                  onTap: localeCubit.setEnglish,
                ),
                languageTile(
                  code: 'fr',
                  title: 'Français',
                  subtitle: AppLocalizations.of(context)!.languageFrench,
                  onTap: localeCubit.setFrench,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Web / tablet: sections open inside the sidebar layout instead of new routes.
  static const int _sectionOverview = 0;
  static const int _sectionTasks = 1;
  static const int _sectionInbox = 2;
  static const int _sectionServices = 3;
  static const int _sectionViolations = 4;
  static const int _sectionAnnouncements = 5;
  static const int _sectionProfile = 6;

  int _section = _sectionOverview;

  bool get _useSidebar => !context.isCompact;

  /// Shows [section] in the sidebar layout on wide screens, otherwise pushes it.
  void _open(int section, void Function(BuildContext) push) {
    if (_useSidebar) {
      setState(() => _section = section);
    } else {
      push(context);
    }
  }

  void _openInbox() => _open(_sectionInbox, AppRouter.goToRequests);

  void _openAnnouncements() => _open(_sectionAnnouncements, AppRouter.goToAnnouncements);

  void _openViolations() => _open(_sectionViolations, AppRouter.goToViolations);

  void _openServices() => _open(_sectionServices, AppRouter.goToStaffServices);

  void _openTasks() => _open(_sectionTasks, AppRouter.goToStaffTasks);

  void _openProfile() => _open(_sectionProfile, AppRouter.goToProfile);

  Widget _sectionPage(int section) {
    switch (section) {
      case _sectionTasks:
        return AppRouter.staffTasksPage();
      case _sectionInbox:
        return AppRouter.requestsPage();
      case _sectionServices:
        return AppRouter.staffServicesPage();
      case _sectionViolations:
        return AppRouter.violationsPage();
      case _sectionAnnouncements:
        return AppRouter.announcementsPage();
      case _sectionProfile:
        return AppRouter.profilePage();
      default:
        return _buildOverview(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_useSidebar) return _buildOverview(context);

    final loc = AppLocalizations.of(context)!;
    final items = [
      SidebarItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard, label: loc.dashboard),
      SidebarItem(icon: Icons.assignment_outlined, selectedIcon: Icons.assignment, label: loc.workflowTasks),
      SidebarItem(icon: Icons.inbox_outlined, selectedIcon: Icons.inbox, label: loc.inbox),
      SidebarItem(icon: Icons.description_outlined, selectedIcon: Icons.description, label: loc.services),
      SidebarItem(icon: Icons.gavel_outlined, selectedIcon: Icons.gavel, label: loc.violations),
      SidebarItem(icon: Icons.campaign_outlined, selectedIcon: Icons.campaign, label: loc.announcements),
    ];

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            title: loc.appTitle,
            subtitle: loc.roleStaff,
            brandIcon: Icons.badge_outlined,
            collapsed: !context.isExpanded,
            items: items,
            // The profile page has no sidebar item, so nothing is highlighted there.
            selectedIndex: _section < items.length ? _section : -1,
            onSelected: (i) => setState(() => _section = i),
            actions: [
              SidebarAction(icon: Icons.person_outline, label: loc.profile, onTap: _openProfile),
              SidebarAction(icon: Icons.language, label: loc.selectLanguage, onTap: _showLanguageSheet),
              SidebarAction(
                icon: Icons.logout,
                label: loc.logout,
                onTap: _isLoggingOut ? () {} : _logout,
                destructive: true,
              ),
            ],
          ),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey(_section),
              child: _sectionPage(_section),
            ),
          ),
        ],
      ),
    );
  }

  /// Quick actions and activity; the whole screen on phones, the first section on web.
  Widget _buildOverview(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.dashboard),
        centerTitle: false,
        actions: _useSidebar ? null : [
          IconButton(
            tooltip: loc.selectLanguage,
            icon: const Icon(Icons.language),
            onPressed: _showLanguageSheet,
          ),
          IconButton(
            tooltip: loc.profile,
            icon: const Icon(Icons.person_outline),
            onPressed: _openProfile,
          ),
          IconButton(
            tooltip: loc.logout,
            icon: _isLoggingOut
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            onPressed: _isLoggingOut ? null : _logout,
          ),
        ],
      ),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeHeader(),

              // Phones only: on web the sidebar already lists every section.
              if (!_useSidebar) ...[
                const SizedBox(height: 24),

                Text(
                  loc.quickActions,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: context.gridColumns,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: context.responsive(
                    compact: AppLayout.actionTileAspectRatioCompact,
                    medium: AppLayout.actionTileAspectRatioWide,
                  ),
                  children: [
                    _ActionCard(
                      title: loc.workflowTasks,
                      icon: Icons.assignment_outlined,
                      iconColor: colors.tertiary,
                      onTap: _openTasks,
                    ),
                    _ActionCard(
                      title: loc.inbox,
                      icon: Icons.inbox_outlined,
                      iconColor: colors.primary,
                      onTap: _openInbox,
                    ),
                    _ActionCard(
                      title: loc.services,
                      icon: Icons.description_outlined,
                      iconColor: colors.secondary,
                      onTap: _openServices,
                    ),
                    _ActionCard(
                      title: loc.violations,
                      icon: Icons.gavel_outlined,
                      iconColor: colors.error,
                      onTap: _openViolations,
                    ),
                    _ActionCard(
                      title: loc.announcements,
                      icon: Icons.campaign_outlined,
                      iconColor: colors.primary,
                      onTap: _openAnnouncements,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              _SectionCard(
                title: loc.recentActivity,
                children: [
                  _ActivityItem(
                    text: loc.newRequest,
                    color: colors.primary,
                  ),
                  _ActivityItem(
                    text: loc.missingDocs,
                    color: Colors.orange,
                  ),
                  _ActivityItem(
                    text: loc.approvedRequest,
                    color: Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _SectionCard(
                title: loc.monthPerformance,
                children: [
                  _PerformanceItem(
                    title: loc.completedRequests,
                    value: '-',
                  ),
                  _PerformanceItem(
                    title: loc.avgTime,
                    value: '-',
                  ),
                  _PerformanceItem(
                    title: loc.satisfaction,
                    value: '-',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: colors.onPrimary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.badge_outlined,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _ResponsiveText(
                  text: loc.dashboard,
                  maxFontSize: 21,
                  minFontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: colors.onPrimary,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 4),
                _ResponsiveText(
                  text: loc.adminDashboardSubtitle,
                  maxFontSize: 13,
                  minFontSize: 9,
                  color: colors.onPrimary.withOpacity(0.78),
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: colors.outline.withOpacity(0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 34),
            const SizedBox(height: 10),
            _ResponsiveText(
              text: title,
              maxFontSize: 14,
              minFontSize: 9,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outline.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResponsiveText(
            text: title,
            maxFontSize: 16,
            minFontSize: 10,
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String text;
  final Color color;

  const _ActivityItem({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          CircleAvatar(
            radius: 5,
            backgroundColor: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceItem extends StatelessWidget {
  final String title;
  final String value;

  const _PerformanceItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final double minFontSize;
  final double maxFontSize;
  final FontWeight fontWeight;
  final Color color;

  const _ResponsiveText({
    required this.text,
    this.textAlign = TextAlign.start,
    this.minFontSize = 9,
    this.maxFontSize = 14,
    this.fontWeight = FontWeight.normal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cleanText = text.trim().isEmpty ? '---' : text.trim();

    double fontSize = maxFontSize;
    final length = cleanText.runes.length;

    if (length > 45) {
      fontSize = maxFontSize - 6;
    } else if (length > 38) {
      fontSize = maxFontSize - 5;
    } else if (length > 31) {
      fontSize = maxFontSize - 4;
    } else if (length > 24) {
      fontSize = maxFontSize - 3;
    } else if (length > 17) {
      fontSize = maxFontSize - 2;
    } else if (length > 11) {
      fontSize = maxFontSize - 1;
    }

    if (fontSize < minFontSize) {
      fontSize = minFontSize;
    }

    Alignment alignment;

    if (textAlign == TextAlign.end || textAlign == TextAlign.right) {
      alignment = Alignment.centerRight;
    } else if (textAlign == TextAlign.center) {
      alignment = Alignment.center;
    } else {
      alignment = Alignment.centerLeft;
    }

    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: Text(
          cleanText,
          maxLines: 1,
          softWrap: false,
          textAlign: textAlign,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}
