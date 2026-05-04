import 'package:baladiyati/app/app_router.dart';
import 'package:baladiyati/core/network/api_client.dart';

import 'package:baladiyati/features/admin/announcements/presentation/screens/announcementscreen.dart';
import 'package:baladiyati/features/admin/violations/presentation/screens/violationpage.dart';
import 'package:baladiyati/features/auth/data/services/auth_api_service.dart';
import 'package:baladiyati/features/auth/presentation/login/screens/login_screen.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';


class DashboardPage extends StatelessWidget {
   DashboardPage({super.key});
  final AuthApiService authApiService = AuthApiService();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      /// 🔹 APP BAR (Profile + Logout)
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F5DA9),
        title: Text(loc.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, "/profile");
            },
          ),
          IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () async {
    await authApiService.logout();

    if (!context.mounted) return;

    AppRouter.goToLogin(context);
  },
),
],
),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// 🔷 HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF2F5DA9),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    Text(
                      loc.employee,
                      style: const TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 20),

                    /// 🔲 STAT CARDS
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _statCard("28", loc.inProgress, Icons.access_time, Colors.orange),
                        _statCard("12", loc.newRequests, Icons.inbox, Colors.blue),
                        _statCard("5", loc.needReview, Icons.warning, Colors.red),
                        _statCard("15", loc.completedToday, Icons.check_circle, Colors.green),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ⚡ QUICK ACTIONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    Text(
                      loc.quickActions,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [

                        _actionCard(
                          loc.services,
                          Icons.description,
                          Colors.green,
                          onTap: () {
                            Navigator.pushNamed(context, "/services");
                          },
                        ),

                        _actionCard(
                          loc.inbox,
                          Icons.inbox,
                          Colors.blue,
                          onTap: () {
                            Navigator.pushNamed(context, "/inbox");
                          },
                        ),

                       _actionCard(
  loc.violations,
  Icons.gavel,
  Colors.red,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ViolationsPage()),
    );
  },),

                        _actionCard(
                          loc.departments,
                          Icons.account_tree,
                          Colors.teal,
                          onTap: () {
                              AppRouter.goToDepartments(context); 

                          },
                        ),

                        _actionCard(
                          loc.employees,
                          Icons.person,
                          Colors.indigo,
                          onTap: () {
                                                  AppRouter.goToEmployees(context); 

                          },
                        ),

                        _actionCard(
  loc.announcements,
  Icons.campaign,
  Colors.orange,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnnouncementsPage()),
    );
  },
),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 📋 ACTIVITY
              _sectionCard(
                title: loc.recentActivity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _activityItem(loc.approvedRequest, Colors.green),
                    _activityItem(loc.newRequest, Colors.blue),
                    _activityItem(loc.missingDocs, Colors.orange),
                  ],
                ),
              ),

              /// 📊 PERFORMANCE
              _sectionCard(
                title: loc.monthPerformance,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _performanceItem("245", loc.completedRequests),
                    _performanceItem("4.5 ${loc.days}", loc.avgTime),
                    _performanceItem("92%", loc.satisfaction),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔲 STAT CARD
  Widget _statCard(String number, String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(number,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  /// ⚡ ACTION CARD (with click)
  Widget _actionCard(String title, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

  /// 📦 SECTION CARD
  Widget _sectionCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  /// 📌 ACTIVITY ITEM
  Widget _activityItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text),
          const SizedBox(width: 10),
          CircleAvatar(radius: 5, backgroundColor: color),
        ],
      ),
    );
  }

  /// 📊 PERFORMANCE ITEM
  Widget _performanceItem(String value, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(title),
        ],
      ),
    );
  }
}