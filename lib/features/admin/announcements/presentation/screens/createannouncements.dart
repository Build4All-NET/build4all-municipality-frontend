import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class CreateAnnouncementPage extends StatelessWidget {
  const CreateAnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.createAnnouncement),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            /// AR TITLE
            Text(loc.titleAr),
            const SizedBox(height: 5),
            TextField(
              decoration: InputDecoration(
                hintText: loc.enterTitleAr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// EN TITLE
            Text(loc.titleEn),
            const SizedBox(height: 5),
            TextField(
              decoration: InputDecoration(
                hintText: loc.enterTitleEn,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// AR CONTENT
            Text(loc.contentAr),
            const SizedBox(height: 5),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: loc.enterContentAr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// EN CONTENT
            Text(loc.contentEn),
            const SizedBox(height: 5),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: loc.enterContentEn,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🚀 SUBMIT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: Text(loc.publishAnnouncement),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F5DA9),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}