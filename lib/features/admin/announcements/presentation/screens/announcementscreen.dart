import 'package:baladiyati/features/admin/announcements/presentation/screens/createannouncements.dart';
import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: Text(loc.announcementsManagement),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ➕ NEW ANNOUNCEMENT BUTTON
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F5DA9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(loc.newAnnouncement),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateAnnouncementPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            /// 📋 LIST (Dummy like your image)
            _announcementCard(loc),
            _announcementCard(loc),
          ],
        ),
      ),
    );
  }

  Widget _announcementCard(AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(loc.published,
                style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Text(loc.sampleTitle,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(loc.sampleDescription),
        ],
      ),
    );
  }
}