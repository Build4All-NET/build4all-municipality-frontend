// lib/features/citizen/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:baladiyati/common/widgets/bottom_nav.dart';
import 'package:baladiyati/features/citizen/payments/presentation/screens/payments_screen.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_bloc.dart';
import 'package:baladiyati/features/citizen/profile/presentation/screens/profile_screen.dart';
import 'package:baladiyati/features/citizen/services/presentation/screens/services_screen.dart';
import 'package:baladiyati/features/citizen/notifications/presentation/screens/notifications_screen.dart';
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

  final String _userName = 'محمد أحمد';
  final String _municipality = 'بلدية بيروت';
  final int _notificationCount = 3;
  final int _activeRequests = 3;
  final int _awaitingPayment = 1;
  final int _completed = 5;

  final List<RecentRequestItem> _recentRequests = const [
    RecentRequestItem(
      id: '1',
      nameAr: 'براءة ذمة بلدية',
      status: 'waiting_payment',
      date: '١٧-٠٣-٢٠٢٦',
    ),
    RecentRequestItem(
      id: '2',
      nameAr: 'شكوى - إنارة شارع',
      status: 'under_review',
      date: '١٥-٠٣-٢٠٢٦',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomePage(),
          const ServicesScreen(),
          const RequestsScreen(),
          const PaymentsScreen(),
          BlocProvider(
            create: (_) => ProfileBloc(),
            child: const ProfileScreen(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          HomeHeader(
            userName: _userName,
            municipality: _municipality,
            notificationCount: _notificationCount,
            activeRequests: _activeRequests,
            awaitingPayment: _awaitingPayment,
            completed: _completed,
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
                  onNewRequest: () => setState(() => _currentIndex = 1),
                  onPayments: () => setState(() => _currentIndex = 3),
                ),
                const SizedBox(height: 20),
                ServiceCategoriesSection(
                  onViewAll: () => setState(() => _currentIndex = 1),
                  onCategoryTap: (_) => setState(() => _currentIndex = 1),
                ),
                const SizedBox(height: 20),
                RecentRequestsSection(
                  requests: _recentRequests,
                  onViewAll: () => setState(() => _currentIndex = 2),
                  onRequestTap: (_) => setState(() => _currentIndex = 2),
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
  }
}
