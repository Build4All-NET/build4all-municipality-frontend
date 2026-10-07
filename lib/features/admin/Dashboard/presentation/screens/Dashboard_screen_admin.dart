import 'package:baladiyati/core/config/app_branding.dart';
import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/core/config/jwt_store.dart';
import 'package:baladiyati/core/l10n/locale_cubit.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/Departement/data/Service/Departement_Api_Service.dart';
import 'package:baladiyati/features/admin/Requests/data/Service/Req_Api_Service.dart';
import 'package:baladiyati/features/admin/Requests/data/model/RequestModel.dart';
import 'package:baladiyati/features/admin/announcements/data/services/Announcement_Api_Service.dart';
import 'package:baladiyati/features/admin/announcements/presentation/screens/announcementscreen.dart';
import 'package:baladiyati/features/admin/manage_service/Data/service/Service_Api_service.dart';
import 'package:baladiyati/features/admin/staff/data/Service/AdminUserApiService.dart';
import 'package:baladiyati/features/admin/staff/data/Service/Employe_Api_Service.dart';
import 'package:baladiyati/features/admin/violations/data/services/violation_api_services.dart';
import 'package:baladiyati/features/admin/violations/presentation/screens/violationpage.dart';
import 'package:baladiyati/features/auth/data/services/AdminTokenStore.dart';
import 'package:baladiyati/features/auth/data/services/auth_api_service.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/common/widgets/app_sidebar.dart';
import 'package:baladiyati/core/l10n/known_names.dart';
import 'package:baladiyati/common/widgets/responsive_center.dart';
import 'package:baladiyati/core/config/app_breakpoints.dart';
import 'package:baladiyati/core/utils/responsive.dart';

// Dashboard grid layout per window size (see AppBreakpoints).
const int _statColumnsCompact = 2;
const int _statColumnsMedium = 3;
const int _statColumnsExpanded = 6; // all six stats in one row on desktop
const double _statAspectRatio = 1.72;
const int _recentRequestsLimit = 5; // web overview list

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

// -1 means the count failed to load (shown as "-")
class _AdminDashboardStats {
  final int announcementsCount;
  final int violationsCount;
  final int departmentsCount;
  final int servicesCount;
  final int employeesCount;
  final int requestsCount;

  /// Newest requests, shown on the web overview.
  final List<RequestModel> recentRequests;

  const _AdminDashboardStats({
    required this.announcementsCount,
    required this.violationsCount,
    required this.departmentsCount,
    required this.servicesCount,
    required this.employeesCount,
    required this.requestsCount,
    this.recentRequests = const [],
  });

  factory _AdminDashboardStats.empty() {
    return const _AdminDashboardStats(
      announcementsCount: -1,
      violationsCount: -1,
      departmentsCount: -1,
      servicesCount: -1,
      employeesCount: -1,
      requestsCount: -1,
    );
  }
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthApiService _authApiService = AuthApiService();

  late final AnnouncementApiService _announcementApiService;
  late final ViolationApiService _violationApiService;
  late final DepartmentApiService _departmentApiService;
  late final ServiceApiService _serviceApiService;
  late final AdminUserApiService _adminUserApiService;
  late final RequestApiService _requestApiService;

  late Future<_AdminDashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();

    _announcementApiService = AnnouncementApiService(DioClient.muni);
    _violationApiService = ViolationApiService(dio: DioClient.muni);
    _departmentApiService = DepartmentApiService(DioClient.muni);
    _serviceApiService = ServiceApiService(DioClient.muni);
    _adminUserApiService = AdminUserApiService(dio: DioClient.muni);
    _requestApiService = RequestApiService(DioClient.muni);

    // Seed first, then load stats so the service count is correct.
    _statsFuture = _seedThenLoadStats();
  }

  /// Seeds default services for this tenant, then loads dashboard stats.
  /// initDefaults() swallows all errors so this never throws.
  Future<_AdminDashboardStats> _seedThenLoadStats() async {
    await _serviceApiService.initDefaults();
    return _loadStats();
  }

  // Each API is wrapped independently — one failure never breaks the others.
  Future<_AdminDashboardStats> _loadStats() async {
    // Requests are fetched once: the list feeds both the count and the recent list.
    final requestsFuture = _requestApiService
        .getAllRequestsAdmin()
        .then<List<RequestModel>?>((v) => v)
        .catchError((_) => null);

    final counts = await Future.wait([
      _announcementApiService
          .getAll()
          .then<int>((v) => v.length)
          .catchError((_) => -1),
      _violationApiService
          .getAllViolations()
          .then<int>((v) => v.length)
          .catchError((_) => -1),
      _departmentApiService
          .getAll()
          .then<int>((v) => v.length)
          .catchError((_) => -1),
      _serviceApiService
          .getServices()
          .then<int>((v) => v.length)
          .catchError((_) => -1),
      _adminUserApiService
          .getUsersByRole(roleName: 'STAFF')
          .then<int>((v) => v.length)
          .catchError((_) => -1),
      requestsFuture.then<int>((v) => v?.length ?? -1),
    ]);

    final recent = [...?await requestsFuture]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return _AdminDashboardStats(
      announcementsCount: counts[0],
      violationsCount: counts[1],
      departmentsCount: counts[2],
      servicesCount: counts[3],
      employeesCount: counts[4],
      requestsCount: counts[5],
      recentRequests: recent.take(_recentRequestsLimit).toList(),
    );
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _loadStats();
    });

    await _statsFuture;
  }

  Future<void> _logout() async {
    // Clear the admin secure-storage token so AuthGate does not
    // re-enter the dashboard on the next app start.
    await AdminTokenStore().clear();
    await JwtStore.clear();
    await _authApiService.logout();

    if (!mounted) return;

    AppRouter.goToLogin(context);
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
  static const int _sectionRequests = 1;
  static const int _sectionServices = 2;
  static const int _sectionDepartments = 3;
  static const int _sectionEmployees = 4;
  static const int _sectionAnnouncements = 5;
  static const int _sectionViolations = 6;
  static const int _sectionCertificates = 7;
  static const int _sectionProfile = 8;

  int _section = _sectionOverview;

  bool get _useSidebar => !context.isCompact;

  /// Shows [section] in the sidebar layout on wide screens, otherwise pushes it.
  Future<void> _open(int section, void Function(BuildContext) push) async {
    if (_useSidebar) {
      setState(() => _section = section);
      return;
    }
    push(context);
  }

  Future<void> _openAnnouncements() async {
    if (_useSidebar) return _open(_sectionAnnouncements, AppRouter.goToAnnouncements);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AnnouncementsPage(),
      ),
    );

    await _refreshStats();
  }

  Future<void> _openViolations() async {
    if (_useSidebar) return _open(_sectionViolations, AppRouter.goToViolations);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ViolationsPage(),
      ),
    );

    await _refreshStats();
  }

  void _openServices() => _open(_sectionServices, AppRouter.goToServices);
  void _openDepartments() => _open(_sectionDepartments, AppRouter.goToDepartments);
  Future<void> _openEmployees() async {
    await _open(_sectionEmployees, AppRouter.goToEmployees);
    await _refreshStats();
  }
  void _openInbox() => _open(_sectionRequests, AppRouter.goToRequests);
  void _openCertificates() => _open(_sectionCertificates, AppRouter.goToCertificates);
  void _openProfile() => _open(_sectionProfile, AppRouter.goToAdminProfile);

  Widget _sectionPage(int section) {
    switch (section) {
      case _sectionRequests:
        return AppRouter.requestsPage();
      case _sectionServices:
        return AppRouter.servicesPage();
      case _sectionDepartments:
        return AppRouter.departmentsPage();
      case _sectionEmployees:
        return AppRouter.employeesPage();
      case _sectionAnnouncements:
        return AppRouter.announcementsPage();
      case _sectionViolations:
        return AppRouter.violationsPage();
      case _sectionCertificates:
        return AppRouter.certificatesPage();
      case _sectionProfile:
        return AppRouter.adminProfilePage();
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
      SidebarItem(icon: Icons.inbox_outlined, selectedIcon: Icons.inbox, label: loc.inbox),
      SidebarItem(icon: Icons.description_outlined, selectedIcon: Icons.description, label: loc.services),
      SidebarItem(icon: Icons.account_tree_outlined, selectedIcon: Icons.account_tree, label: loc.departments),
      SidebarItem(icon: Icons.badge_outlined, selectedIcon: Icons.badge, label: loc.employees),
      SidebarItem(icon: Icons.campaign_outlined, selectedIcon: Icons.campaign, label: loc.announcements),
      SidebarItem(icon: Icons.gavel_outlined, selectedIcon: Icons.gavel, label: loc.violations),
      SidebarItem(icon: Icons.verified_outlined, selectedIcon: Icons.verified, label: loc.certificate),
    ];

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            title: brandName(context),
            subtitle: loc.roleOwner,
            brandIcon: Icons.admin_panel_settings_outlined,
            collapsed: !context.isExpanded,
            items: items,
            // The profile page has no sidebar item, so nothing is highlighted there.
            selectedIndex: _section < items.length ? _section : -1,
            onSelected: (i) {
              setState(() => _section = i);
              if (i == _sectionOverview) _refreshStats();
            },
            actions: [
              SidebarAction(icon: Icons.person_outline, label: loc.profile, onTap: _openProfile),
              SidebarAction(icon: Icons.language, label: loc.selectLanguage, onTap: _showLanguageSheet),
              SidebarAction(icon: Icons.logout, label: loc.logout, onTap: _logout, destructive: true),
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

  String _formatCount(int count) => count < 0 ? '-' : '$count';

  /// Stats and quick actions; the whole screen on phones, the first section on web.
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
            onPressed: () => AppRouter.goToAdminProfile(context),
          ),
          IconButton(
            tooltip: loc.logout,
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStats,
        child: FutureBuilder<_AdminDashboardStats>(
          future: _statsFuture,
          builder: (context, snapshot) {
            final stats = snapshot.data ?? _AdminDashboardStats.empty();
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            final bool hasNetworkError = !isLoading &&
                stats.announcementsCount < 0 &&
                stats.violationsCount < 0 &&
                stats.departmentsCount < 0 &&
                stats.servicesCount < 0 &&
                stats.employeesCount < 0 &&
                stats.requestsCount < 0;

            return ResponsiveCenter(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasNetworkError)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.wifi_off,
                              color: colors.onErrorContainer,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loc.networkErrorBanner,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    _WelcomeHeader(isLoading: isLoading),

                    const SizedBox(height: 14),

                    GridView.count(
                      crossAxisCount: context.responsive(
                        compact: _statColumnsCompact,
                        medium: _statColumnsMedium,
                        expanded: _statColumnsExpanded,
                      ),
                      shrinkWrap: true,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: _statAspectRatio,
                      children: [
                        _StatCard(
                          title: loc.announcements,
                          onTap: _openAnnouncements,
                          value: isLoading
                              ? '...'
                              : _formatCount(stats.announcementsCount),
                          icon: Icons.campaign_outlined,
                          iconColor: colors.primary,
                        ),
                        _StatCard(
                          title: loc.violations,
                          onTap: _openViolations,
                          value: isLoading
                              ? '...'
                              : _formatCount(stats.violationsCount),
                          icon: Icons.gavel_outlined,
                          iconColor: colors.error,
                        ),
                        _StatCard(
                          title: loc.departments,
                          onTap: _openDepartments,
                          value: isLoading
                              ? '...'
                              : _formatCount(stats.departmentsCount),
                          icon: Icons.account_tree_outlined,
                          iconColor: colors.tertiary,
                        ),
                        _StatCard(
                          title: loc.services,
                          onTap: _openServices,
                          value:
                              isLoading ? '...' : _formatCount(stats.servicesCount),
                          icon: Icons.description_outlined,
                          iconColor: colors.secondary,
                        ),
                        _StatCard(
                          title: loc.employees,
                          onTap: _openEmployees,
                          value:
                              isLoading ? '...' : _formatCount(stats.employeesCount),
                          icon: Icons.groups_outlined,
                          iconColor: colors.primary,
                        ),
                        _StatCard(
                          title: loc.requestsCount,
                          onTap: _openInbox,
                          value:
                              isLoading ? '...' : _formatCount(stats.requestsCount),
                          icon: Icons.inbox_outlined,
                          iconColor: colors.outline,
                        ),
                      ],
                    ),

                    // Web: latest requests fill the overview (sections live in the sidebar).
                    if (_useSidebar) ...[
                      const SizedBox(height: 22),
                      _RecentRequestsPanel(
                        requests: stats.recentRequests,
                        isLoading: isLoading,
                        onViewAll: _openInbox,
                      ),
                    ],

                    // Phones only: on web the sidebar already lists every section.
                    if (!_useSidebar) ...[
                      const SizedBox(height: 22),

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
                            title: loc.announcements,
                            icon: Icons.campaign_outlined,
                            iconColor: colors.primary,
                            onTap: _openAnnouncements,
                          ),
                          _ActionCard(
                            title: loc.violations,
                            icon: Icons.gavel_outlined,
                            iconColor: colors.error,
                            onTap: _openViolations,
                          ),
                          _ActionCard(
                            title: loc.services,
                            icon: Icons.description_outlined,
                            iconColor: colors.secondary,
                            onTap: _openServices,
                          ),
                          _ActionCard(
                            title: loc.inbox,
                            icon: Icons.inbox_outlined,
                            iconColor: colors.primary,
                            onTap: _openInbox,
                          ),
                          _ActionCard(
                            title: loc.departments,
                            icon: Icons.account_tree_outlined,
                            iconColor: colors.tertiary,
                            onTap: _openDepartments,
                          ),
                          _ActionCard(
                            title: loc.employees,
                            icon: Icons.badge_outlined,
                            iconColor: colors.primary,
                            onTap: _openEmployees,
                          ),
                          _ActionCard(
                            title: loc.certificate,
                            icon: Icons.verified_outlined,
                            iconColor: colors.primary,
                            onTap: _openCertificates,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeHeader extends StatelessWidget {
  final bool isLoading;

  const _WelcomeHeader({required this.isLoading});

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
              Icons.admin_panel_settings_outlined,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  loc.dashboard,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.adminDashboardSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withOpacity(0.78),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.onPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outline.withOpacity(0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.04),
                blurRadius: 9,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: colors.onSurface.withOpacity(0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Newest citizen requests on the web overview, with a link to the inbox.
class _RecentRequestsPanel extends StatelessWidget {
  final List<RequestModel> requests;
  final bool isLoading;
  final VoidCallback onViewAll;

  const _RecentRequestsPanel({
    required this.requests,
    required this.isLoading,
    required this.onViewAll,
  });

  Color _statusColor(ColorScheme colors, String status) {
    switch (status.trim().toUpperCase()) {
      case 'APPROVED':
      case 'COMPLETED':
      case 'TAX_PAID':
        return colors.primary;
      case 'REJECTED':
      case 'CANCELLED':
      case 'TAX_REJECTED':
        return colors.error;
      case 'IN_PROGRESS':
      case 'UNDER_REVIEW':
        return colors.tertiary;
      default:
        return colors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    loc.recentRequests,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(onPressed: onViewAll, child: Text(loc.viewAll)),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (requests.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  loc.noRequests,
                  style: theme.textTheme.bodyMedium?.copyWith(color: colors.outline),
                ),
              ),
            )
          else
            for (final request in requests) ...[
              Divider(height: 1, color: colors.outline.withOpacity(0.12)),
              ListTile(
                onTap: onViewAll,
                leading: CircleAvatar(
                  backgroundColor: colors.primary.withOpacity(0.10),
                  child: Icon(Icons.description_outlined, color: colors.primary, size: 20),
                ),
                title: Text(
                  request.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  [request.trackingNumber, request.citizenName, request.createdAt.split('T').first]
                      .where((part) => part.trim().isNotEmpty)
                      .join('  ·  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: colors.outline),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(colors, request.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    localizedRequestStatus(loc, request.status),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _statusColor(colors, request.status),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}
