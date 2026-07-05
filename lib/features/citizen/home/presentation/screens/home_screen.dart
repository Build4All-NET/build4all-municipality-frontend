import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/core/config/env.dart';
import 'package:baladiyati/features/citizen/ai_chat/presentation/screens/ai_chat_screen.dart';

import 'package:baladiyati/common/widgets/bottom_nav.dart';
import 'package:baladiyati/features/citizen/payments/presentation/screens/payments_screen.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_bloc.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_event.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_state.dart';
import 'package:baladiyati/features/citizen/profile/presentation/screens/profile_screen.dart';
import 'package:baladiyati/features/citizen/services/presentation/bloc/services_bloc.dart';
import 'package:baladiyati/features/citizen/services/presentation/bloc/services_event.dart';
import 'package:baladiyati/features/citizen/services/presentation/screens/services_screen.dart';
import 'package:baladiyati/features/citizen/notifications/presentation/screens/notifications_screen.dart';
import 'package:baladiyati/features/citizen/notifications/data/services/notification_api_service.dart';
import 'package:baladiyati/features/citizen/requests/domain/entities/request_entity.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_bloc.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_event.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_state.dart';
import 'package:baladiyati/features/citizen/requests/presentation/screens/requests_screen.dart';

import '../widgets/home_header.dart';
import '../widgets/quick_actions.dart';
import '../widgets/service_categories.dart';
import '../widgets/recent_requests.dart';
import '../widgets/announcements.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _notificationCount = 0;

  late final ProfileBloc _profileBloc;
  late final RequestsBloc _requestsBloc;
  late final CitizenServicesBloc _servicesBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc()..add(ProfileLoadRequested());
    _requestsBloc = RequestsBloc()..add(RequestsLoadRequested());
    _servicesBloc = CitizenServicesBloc()..add(CitizenServicesLoadRequested());
    _loadNotificationCount();
  }

  void _loadNotificationCount() async {
    try {
      final api = NotificationApiService();
      final notifs = await api.getMyNotifications(unreadOnly: true);
      if (mounted) setState(() => _notificationCount = notifs.length);
    } catch (_) {}
  }

  @override
  void dispose() {
    _profileBloc.close();
    _requestsBloc.close();
    _servicesBloc.close();
    super.dispose();
  }

  // Active = still being processed
  int _countActive(List<RequestEntity> r) => r.where((x) {
        final s = x.status.toUpperCase();
        return s == 'SUBMITTED' ||
            s == 'UNDER_REVIEW' ||
            s == 'DOCUMENTS_MISSING' ||
            s == 'IN_PROGRESS';
      }).length;

  // Awaiting = approved but waiting for tax payment
  int _countAwaiting(List<RequestEntity> r) => r.where((x) {
        final s = x.status.toUpperCase();
        return s == 'APPROVED' || s == 'TAX_PAID';
      }).length;

  // Completed = fully done
  int _countCompleted(List<RequestEntity> r) =>
      r.where((x) => x.status.toUpperCase() == 'COMPLETED').length;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileBloc),
        BlocProvider.value(value: _requestsBloc),
        BlocProvider.value(value: _servicesBloc),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomePage(),
            BlocProvider.value(
              value: _servicesBloc,
              child: const ServicesScreen(),
            ),
            BlocProvider.value(
              value: _requestsBloc,
              child: const RequestsScreen(),
            ),
            const PaymentsScreen(),
            BlocProvider.value(
              value: _profileBloc,
              child: const ProfileScreen(),
            ),
          ],
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AiChatScreen(),
                  ),
                ),
                tooltip: AppLocalizations.of(context)!.aiChatTitle,
                child: const Icon(Icons.auto_awesome_outlined),
              )
            : null,
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) {
            if (i == 2) {
              _requestsBloc.add(RequestsRefreshRequested());
            }
            setState(() => _currentIndex = i);
          },
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        return BlocBuilder<RequestsBloc, RequestsState>(
          builder: (context, requestsState) {
            final userName = profileState.profile?.fullName ?? '...';
            final municipality =
                (profileState.profile?.municipalityName?.isNotEmpty ?? false)
                    ? profileState.profile!.municipalityName!
                    : profileState.isLoading
                        ? '...'
                        : Env.appName;

            final requests = requestsState.requests;

            return SingleChildScrollView(
              child: Column(
                children: [
                  HomeHeader(
                    userName: userName,
                    municipality: municipality,
                    notificationCount: _notificationCount,
                    activeRequests: _countActive(requests),
                    awaitingPayment: _countAwaiting(requests),
                    completed: _countCompleted(requests),
                    isLoading: requestsState.isLoading,
                    onNotificationTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                      _loadNotificationCount();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        QuickActions(
                          onNewRequest: () =>
                              setState(() => _currentIndex = 1),
                          onPayments: () =>
                              setState(() => _currentIndex = 3),
                        ),
                        const SizedBox(height: 20),
                        ServiceCategoriesSection(
                          onViewAll: () =>
                              setState(() => _currentIndex = 1),
                          onCategoryTap: () =>
                              setState(() => _currentIndex = 1),
                        ),
                        const SizedBox(height: 20),
                        RecentRequestsSection(
                          isLoading: requestsState.isLoading,
                          requests: requests.take(2).map((r) =>
                            RecentRequestItem(
                              id: r.id,
                              nameAr: r.title.isNotEmpty
                                  ? r.title
                                  : (r.serviceName ?? r.trackingNumber),
                              status: r.status.toLowerCase(),
                              date: _formatDate(r.createdAt),
                            ),
                          ).toList(),
                          onViewAll: () =>
                              setState(() => _currentIndex = 2),
                          onRequestTap: (_) =>
                              setState(() => _currentIndex = 2),
                        ),
                        const SizedBox(height: 20),
                        const AnnouncementsCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
