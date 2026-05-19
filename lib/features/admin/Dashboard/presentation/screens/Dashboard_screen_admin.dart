import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/core/l10n/locale_cubit.dart';
import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/Departement/data/Service/Departement_Api_Service.dart';
import 'package:baladiyati/features/admin/announcements/data/services/Announcement_Api_Service.dart';
import 'package:baladiyati/features/admin/announcements/presentation/screens/announcementscreen.dart';
import 'package:baladiyati/features/admin/manage_service/Data/service/Service_Api_service.dart';
import 'package:baladiyati/features/admin/staff/data/Service/Employe_Api_Service.dart';
import 'package:baladiyati/features/admin/violations/data/services/violation_api_services.dart';
import 'package:baladiyati/features/admin/violations/presentation/screens/violationpage.dart';
import 'package:baladiyati/features/auth/data/services/auth_api_service.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  const _AdminDashboardStats({
    required this.announcementsCount,
    required this.violationsCount,
    required this.departmentsCount,
    required this.servicesCount,
    required this.employeesCount,
  });

  factory _AdminDashboardStats.empty() {
    return const _AdminDashboardStats(
      announcementsCount: -1,
      violationsCount: -1,
      departmentsCount: -1,
      servicesCount: -1,
      employeesCount: -1,
    );
  }
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthApiService _authApiService = AuthApiService();

  late final AnnouncementApiService _announcementApiService;
  late final ViolationApiService _violationApiService;
  late final DepartmentApiService _departmentApiService;
  late final ServiceApiService _serviceApiService;
  late final EmployeeApiService _employeeApiService;

  late Future<_AdminDashboardStats> _statsFuture;

  @override
  void initState() {
    super.initState();

    _announcementApiService = AnnouncementApiService(DioClient.muni);
    _violationApiService = ViolationApiService(dio: DioClient.muni);
    _departmentApiService = DepartmentApiService(DioClient.muni);
    _serviceApiService = ServiceApiService(DioClient.muni);
    _employeeApiService = EmployeeApiService(DioClient.muni);

    _statsFuture = _loadStats();
  }

  // Each API is wrapped independently — one failure never breaks the others.
  Future<_AdminDashboardStats> _loadStats() async {
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
      _employeeApiService
          .getEmployees()
          .then<int>((v) => v.length)
          .catchError((_) => -1),
    ]);

    return _AdminDashboardStats(
      announcementsCount: counts[0],
      violationsCount: counts[1],
      departmentsCount: counts[2],
      servicesCount: counts[3],
      employeesCount: counts[4],
    );
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _loadStats();
    });

    await _statsFuture;
  }

  Future<void> _logout() async {
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
                  subtitle: 'Arabic',
                  onTap: localeCubit.setArabic,
                ),
                languageTile(
                  code: 'en',
                  title: 'English',
                  subtitle: 'English',
                  onTap: localeCubit.setEnglish,
                ),
                languageTile(
                  code: 'fr',
                  title: 'Français',
                  subtitle: 'French',
                  onTap: localeCubit.setFrench,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openAnnouncements() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AnnouncementsPage(),
      ),
    );

    await _refreshStats();
  }

  Future<void> _openViolations() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ViolationsPage(),
      ),
    );

    await _refreshStats();
  }

  void _openServices() => AppRouter.goToServices(context);
  void _openDepartments() => AppRouter.goToDepartments(context);
  void _openEmployees() => AppRouter.goToEmployees(context);
  void _openInbox() => AppRouter.goToRequests(context);

  String _formatCount(int count) => count < 0 ? '-' : '$count';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.dashboard),
        centerTitle: false,
        actions: [
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

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WelcomeHeader(isLoading: isLoading),

                  const SizedBox(height: 16),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.28,
                    children: [
                      _StatCard(
                        title: loc.announcements,
                        value: isLoading ? '...' : _formatCount(stats.announcementsCount),
                        icon: Icons.campaign_outlined,
                        iconColor: colors.primary,
                      ),
                      _StatCard(
                        title: loc.violations,
                        value: isLoading ? '...' : _formatCount(stats.violationsCount),
                        icon: Icons.gavel_outlined,
                        iconColor: colors.error,
                      ),
                      _StatCard(
                        title: loc.departments,
                        value: isLoading ? '...' : _formatCount(stats.departmentsCount),
                        icon: Icons.account_tree_outlined,
                        iconColor: colors.tertiary,
                      ),
                      _StatCard(
                        title: loc.services,
                        value: isLoading ? '...' : _formatCount(stats.servicesCount),
                        icon: Icons.description_outlined,
                        iconColor: colors.secondary,
                      ),
                      _StatCard(
                        title: loc.employees,
                        value: isLoading ? '...' : _formatCount(stats.employeesCount),
                        icon: Icons.groups_outlined,
                        iconColor: colors.primary,
                      ),
                      _StatCard(
                        title: loc.inbox,
                        value: '-',
                        icon: Icons.inbox_outlined,
                        iconColor: colors.outline,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    loc.quickActions,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.12,
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
                    ],
                  ),
                ],
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
                  isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withOpacity(0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 29),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.72),
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
