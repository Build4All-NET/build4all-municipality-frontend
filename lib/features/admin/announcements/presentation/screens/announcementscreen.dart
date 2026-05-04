import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/announcements/data/Repository/announcement_Repository_Impl.dart';
import 'package:baladiyati/features/admin/announcements/data/services/Announcement_Api_Service.dart';
import 'package:baladiyati/features/admin/announcements/domain/Usecases/Create_Announcement.dart';
import 'package:baladiyati/features/admin/announcements/domain/Usecases/Delete_Announcement.dart';
import 'package:baladiyati/features/admin/announcements/domain/Usecases/Get_Announcement.dart';
import 'package:baladiyati/features/admin/announcements/domain/Usecases/Update_Announcement.dart';
import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';
import 'package:baladiyati/features/admin/announcements/presentation/bloc/Announcement_Event.dart';
import 'package:baladiyati/features/admin/announcements/presentation/bloc/Announcement_bloc.dart';
import 'package:baladiyati/features/admin/announcements/presentation/bloc/Announcement_state.dart';
import 'package:baladiyati/features/admin/announcements/presentation/screens/createannouncements.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AnnouncementRepositoryImpl(
      AnnouncementApiService(DioClient.muni),
    );

    return BlocProvider(
      create: (_) => AnnouncementBloc(
        createAnnouncement: CreateAnnouncement(repo),
        getAnnouncements: GetAnnouncements(repo),
        updateAnnouncement: UpdateAnnouncement(repo),
        deleteAnnouncement: DeleteAnnouncement(repo),
      )..add(LoadAnnouncements()),
      child: const AnnouncementsBody(),
    );
  }
}

class AnnouncementsBody extends StatelessWidget {
  const AnnouncementsBody({super.key});

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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2F5DA9),
        icon: const Icon(Icons.add),
        label: Text(loc.newAnnouncement),
        onPressed: () {
          final bloc = context.read<AnnouncementBloc>();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: const CreateAnnouncementPage(),
              ),
            ),
          );
        },
      ),
      body: BlocBuilder<AnnouncementBloc, AnnouncementState>(
        builder: (context, state) {
          if (state is AnnouncementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AnnouncementError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (state is AnnouncementLoaded) {
            if (state.list.isEmpty) {
              return Center(
                child: Text(loc.announcements),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AnnouncementBloc>().add(LoadAnnouncements());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.list.length,
                itemBuilder: (context, index) {
                  final announcement = state.list[index];
                  return _AnnouncementCard(announcement: announcement);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const _AnnouncementCard({
    required this.announcement,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 2),
            color: Color(0x11000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  loc.published,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF2F5DA9)),
                onPressed: () {
                  final bloc = context.read<AnnouncementBloc>();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: CreateAnnouncementPage(
                          announcement: announcement,
                        ),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: announcement.id == null
                    ? null
                    : () => _confirmDelete(context, announcement.id!),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            announcement.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            announcement.content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
            ),
          ),
          if (announcement.createdAt != null) ...[
            const SizedBox(height: 10),
            Text(
              announcement.createdAt!.toString().split('.').first,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(loc.announcements),
          content: const Text('Delete this announcement?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
                context
                    .read<AnnouncementBloc>()
                    .add(DeleteAnnouncementEvent(id));
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}