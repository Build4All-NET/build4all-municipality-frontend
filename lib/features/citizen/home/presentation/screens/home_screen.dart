// lib/features/citizen/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:baladiyati/common/widgets/bottom_nav.dart';
import 'package:baladiyati/features/citizen/payments/presentation/screens/payments_screen.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_bloc.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_event.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_state.dart';
import 'package:baladiyati/features/citizen/profile/presentation/screens/profile_screen.dart';
import 'package:baladiyati/features/citizen/services/presentation/screens/services_screen.dart';
import 'package:baladiyati/features/citizen/notifications/presentation/screens/notifications_screen.dart';
import 'package:baladiyati/features/citizen/requests/data/models/request_model.dart';
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

  late final ProfileBloc _profileBloc;
  late final RequestsBloc _requestsBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc()..add(ProfileLoadRequested());
    _requestsBloc = RequestsBloc()..add(RequestsLoadRequested());
  }

  @override
  void dispose() {
    _profileBloc.close();
    _requestsBloc.close();
    super.dispose();
  }

  // ── Map raw API string → new RequestStatus enum ───────────────────────────
  RequestStatus _toEnum(String raw) {
    switch (raw.toUpperCase()) {
      case 'DRAFT':             return RequestStatus.draft;
      case 'SUBMITTED':         return RequestStatus.submitted;
      case 'UNDER_REVIEW':      return RequestStatus.underReview;
      case 'DOCUMENTS_MISSING': return RequestStatus.documentsMissing;
      case 'IN_PROGRESS':       return RequestStatus.inProgress;
      case 'APPROVED':          return RequestStatus.approved;
      case 'TAX_PAID':          return RequestStatus.taxPaid;
      case 'TAX_REJECTED':      return RequestStatus.taxRejected;
      case 'COMPLETED':         return RequestStatus.completed;
      case 'REJECTED':          return RequestStatus.rejected;
      case 'CANCELLED':         return RequestStatus.cancelled;
      default:                  return RequestStatus.draft;
    }
  }

  // ── Map status → string key for RecentRequestItem ────────────────────────
  String _statusKey(String raw) {
    switch (_toEnum(raw)) {
      case RequestStatus.draft:             return 'draft';
      case RequestStatus.submitted:         return 'submitted';
      case RequestStatus.underReview:       return 'under_review';
      case RequestStatus.documentsMissing:  return 'documents_missing';
      case RequestStatus.inProgress:        return 'in_progress';
      case RequestStatus.approved:          return 'approved';
      case RequestStatus.taxPaid:           return 'tax_paid';
      case RequestStatus.taxRejected:       return 'tax_rejected';
      case RequestStatus.completed:         return 'completed';
      case RequestStatus.rejected:          return 'rejected';
      case RequestStatus.cancelled:         return 'cancelled';
    }
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  // Active = still being processed
  int _countActive(List<RequestModel> r) => r.where((x) => [
        RequestStatus.submitted,
        RequestStatus.underReview,
        RequestStatus.documentsMissing,
        RequestStatus.inProgress,
      ].contains(_toEnum(x.status))).length;

  // Awaiting = approved but waiting for tax payment
  int _countAwaiting(List<RequestModel> r) => r.where((x) => [
        RequestStatus.approved,
        RequestStatus.taxPaid,
      ].contains(_toEnum(x.status))).length;

  // Completed = fully done
  int _countCompleted(List<RequestModel> r) =>
      r.where((x) => _toEnum(x.status) == RequestStatus.completed).length;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileBloc),
        BlocProvider.value(value: _requestsBloc),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomePage(),
            const ServicesScreen(),
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
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
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
                        : 'غير محدد';

            final requests = requestsState.requests;

            return SingleChildScrollView(
              child: Column(
                children: [
                  HomeHeader(
                    userName: userName,
                    municipality: municipality,
                    notificationCount: 3,
                    activeRequests: _countActive(requests),
                    awaitingPayment: _countAwaiting(requests),
                    completed: _countCompleted(requests),
                    onNotificationTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
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
                          onCategoryTap: (_) =>
                              setState(() => _currentIndex = 1),
                        ),
                        const SizedBox(height: 20),
                        RecentRequestsSection(
                          requests: requests.take(2).map((r) =>
                            RecentRequestItem(
                              id: r.id,
                              nameAr: r.nameAr,
                              status: _statusKey(r.status),
                              date: r.date,
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
}