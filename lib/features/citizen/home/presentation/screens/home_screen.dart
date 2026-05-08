// lib/features/citizen/home/presentation/screens/home_screen.dart

import 'package:baladiyati/common/widgets/bottom_nav.dart';
import 'package:baladiyati/core/config/app_sizes.dart';
import 'package:baladiyati/features/citizen/notifications/presentation/screens/notifications_screen.dart';
import 'package:baladiyati/features/citizen/payments/presentation/screens/payments_screen.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_bloc.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_event.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_state.dart';
import 'package:baladiyati/features/citizen/profile/presentation/screens/profile_screen.dart';
import 'package:baladiyati/features/citizen/requests/data/models/request_model.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_bloc.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_event.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_state.dart';
import 'package:baladiyati/features/citizen/requests/presentation/screens/requests_screen.dart';
import 'package:baladiyati/features/citizen/requests/presentation/widgets/request_status_badge.dart';
import 'package:baladiyati/features/citizen/services/presentation/screens/services_screen.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/announcements.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_requests.dart';
import '../widgets/service_categories.dart';

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

    _profileBloc = ProfileBloc()
      ..add(
        ProfileLoadRequested(),
      );

    _requestsBloc = RequestsBloc()
      ..add(
        const RequestsLoadRequested(),
      );
  }

  @override
  void dispose() {
    _profileBloc.close();
    _requestsBloc.close();
    super.dispose();
  }

  CitizenRequestStatus _statusOf(String rawStatus) {
    return requestStatusFromString(rawStatus);
  }

  String _statusKey(String rawStatus) {
    switch (_statusOf(rawStatus)) {
      case CitizenRequestStatus.draft:
        return 'draft';
      case CitizenRequestStatus.submitted:
        return 'submitted';
      case CitizenRequestStatus.underReview:
        return 'under_review';
      case CitizenRequestStatus.waitingPayment:
        return 'waiting_payment';
      case CitizenRequestStatus.approved:
        return 'approved';
      case CitizenRequestStatus.inField:
        return 'in_field';
      case CitizenRequestStatus.delivered:
        return 'delivered';
      case CitizenRequestStatus.rejected:
        return 'rejected';
      case CitizenRequestStatus.cancelled:
        return 'cancelled';
    }
  }

  int _countActive(List<RequestModel> requests) {
    return requests.where((request) {
      final status = _statusOf(request.status);

      return status == CitizenRequestStatus.submitted ||
          status == CitizenRequestStatus.underReview ||
          status == CitizenRequestStatus.inField ||
          status == CitizenRequestStatus.approved;
    }).length;
  }

  int _countAwaitingPayment(List<RequestModel> requests) {
    return requests.where((request) {
      return _statusOf(request.status) == CitizenRequestStatus.waitingPayment;
    }).length;
  }

  int _countCompleted(List<RequestModel> requests) {
    return requests.where((request) {
      return _statusOf(request.status) == CitizenRequestStatus.delivered;
    }).length;
  }

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _refreshHomeData() async {
    _profileBloc.add(ProfileLoadRequested());
    _requestsBloc.add(const RequestsRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileBloc),
        BlocProvider.value(value: _requestsBloc),
      ],
      child: Scaffold(
        backgroundColor: cs.background,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomePage(),
            const ServicesScreen(),
            const RequestsScreen(),
            const PaymentsScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          onTap: _goToTab,
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        return BlocBuilder<RequestsBloc, RequestsState>(
          builder: (context, requestsState) {
            final l10n = AppLocalizations.of(context)!;

            final userName = profileState.profile?.fullName?.trim().isNotEmpty == true
                ? profileState.profile!.fullName!
                : '...';

            final municipality =
                profileState.profile?.municipalityName?.trim().isNotEmpty == true
                    ? profileState.profile!.municipalityName!
                    : profileState.isLoading
                        ? '...'
                        : l10n.notAvailable;

            final requests = requestsState.requests;

            return RefreshIndicator(
              onRefresh: _refreshHomeData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    HomeHeader(
                      userName: userName,
                      municipality: municipality,
                      notificationCount: 0,
                      activeRequests: _countActive(requests),
                      awaitingPayment: _countAwaitingPayment(requests),
                      completed: _countCompleted(requests),
                      onNotificationTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSizes.paddingSmall),
                          QuickActions(
                            onNewRequest: () => _goToTab(1),
                            onPayments: () => _goToTab(3),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          ServiceCategoriesSection(
                            onViewAll: () => _goToTab(1),
                            onCategoryTap: (_) => _goToTab(1),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          RecentRequestsSection(
                            requests: requests.take(2).map((request) {
                              return RecentRequestItem(
                                id: request.id,
                                nameAr: request.displayTitle,
                                status: _statusKey(request.status),
                                date: request.date,
                              );
                            }).toList(),
                            onViewAll: () => _goToTab(2),
                            onRequestTap: (_) => _goToTab(2),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          const AnnouncementsCard(),
                          const SizedBox(height: AppSizes.paddingLarge),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}