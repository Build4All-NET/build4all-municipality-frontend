import 'package:baladiyati/common/widgets/app_toast.dart';
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

class AnnouncementsBody extends StatefulWidget {
  const AnnouncementsBody({super.key});

  @override
  State<AnnouncementsBody> createState() => _AnnouncementsBodyState();
}

class _AnnouncementsBodyState extends State<AnnouncementsBody> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  List<Announcement>? _cachedList;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Announcement> _filter(List<Announcement> list) {
    final q = _query.trim().toLowerCase();

    if (q.isEmpty) return list;

    return list.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.content.toLowerCase().contains(q);
    }).toList();
  }

  void _reload() {
    context.read<AnnouncementBloc>().add(LoadAnnouncements());
  }

  Future<void> _openCreateScreen() async {
    final bloc = context.read<AnnouncementBloc>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const CreateAnnouncementPage(),
        ),
      ),
    );

    _reload();
  }

  Future<void> _openEditScreen(Announcement announcement) async {
    final bloc = context.read<AnnouncementBloc>();

    await Navigator.push(
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

    _reload();
  }

  void _confirmDelete(Announcement announcement) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    if (announcement.id == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(loc.confirmDelete),
          content: Text(loc.deleteAnnouncementConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(loc.cancel),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              icon: const Icon(Icons.delete_outline),
              label: Text(loc.delete),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AnnouncementBloc>().add(
                      DeleteAnnouncementEvent(announcement.id!),
                    );
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return '-';

    final local = date.toLocal();
    final materialLoc = MaterialLocalizations.of(context);
    final day = materialLoc.formatMediumDate(local);
    final time = TimeOfDay.fromDateTime(local).format(context);

    return '$day • $time';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.announcementsManagement),
        actions: [
          IconButton(
            tooltip: loc.update,
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
          IconButton(
            tooltip: loc.newAnnouncement,
            icon: const Icon(Icons.add),
            onPressed: _openCreateScreen,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateScreen,
        icon: const Icon(Icons.add),
        label: Text(loc.newAnnouncement),
      ),
      body: BlocConsumer<AnnouncementBloc, AnnouncementState>(
        listener: (context, state) {
          if (state is AnnouncementError) {
            AppToast.show(
              context,
              message: state.message,
              type: AppToastType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is AnnouncementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Operation error (delete/update/create): keep list visible, toast shown in listener.
          if (state is AnnouncementError && _cachedList == null) {
            return _ErrorState(message: state.message, onRetry: _reload);
          }

          final announcements = state is AnnouncementLoaded
              ? state.list
              : _cachedList ?? [];

          if (state is AnnouncementLoaded) {
            _cachedList = state.list;
          }

          final filtered = _filter(announcements);

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                _SearchField(
                  controller: _searchController,
                  hint: loc.search,
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                _SummaryStrip(
                  total: announcements.length,
                  shown: filtered.length,
                ),

                const SizedBox(height: 14),

                if (filtered.isEmpty)
                  _EmptyState(
                    title: loc.noAnnouncements,
                    subtitle: loc.noAnnouncementsHint,
                  )
                else
                  ...filtered.map(
                    (announcement) => _AnnouncementCard(
                      announcement: announcement,
                      createdAt: _formatDate(context, announcement.createdAt),
                      onEdit: () => _openEditScreen(announcement),
                      onDelete: () => _confirmDelete(announcement),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colors.outline.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final int total;
  final int shown;

  const _SummaryStrip({
    required this.total,
    required this.shown,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.campaign_outlined,
            color: colors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loc.announcements,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            loc.shownOfTotal(shown, total),
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final String createdAt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AnnouncementCard({
    required this.announcement,
    required this.createdAt,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outline.withOpacity(0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  avatar: Icon(
                    Icons.check_circle_outline,
                    size: 17,
                    color: colors.primary,
                  ),
                  label: Text(loc.published),
                  backgroundColor: colors.primary.withOpacity(0.08),
                  side: BorderSide(
                    color: colors.primary.withOpacity(0.14),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: loc.edit,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: colors.primary,
                  ),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: loc.delete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: colors.error,
                  ),
                  onPressed: announcement.id == null ? null : onDelete,
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              announcement.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              announcement.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.75),
                height: 1.35,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 17,
                  color: colors.onSurface.withOpacity(0.55),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    createdAt,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withOpacity(0.58),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: Column(
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 58,
            color: colors.onSurface.withOpacity(0.35),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 54,
              color: colors.error,
            ),
            const SizedBox(height: 12),
            Text(
              loc.networkError,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.68),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(loc.update),
            ),
          ],
        ),
      ),
    );
  }
}