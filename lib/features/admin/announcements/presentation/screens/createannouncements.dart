import 'package:baladiyati/features/admin/announcements/domain/entities/announcement.dart';
import 'package:baladiyati/features/admin/announcements/presentation/bloc/Announcement_Event.dart';
import 'package:baladiyati/features/admin/announcements/presentation/bloc/Announcement_bloc.dart';
import 'package:baladiyati/features/admin/announcements/presentation/bloc/Announcement_state.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAnnouncementPage extends StatefulWidget {
  final Announcement? announcement;

  const CreateAnnouncementPage({
    super.key,
    this.announcement,
  });

  bool get isEdit => announcement != null;

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool _submitted = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.announcement?.title ?? '',
    );

    _contentController = TextEditingController(
      text: widget.announcement?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitted = true);

    final announcement = Announcement(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );

    if (widget.isEdit) {
      final id = widget.announcement!.id;

      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing announcement ID')),
        );
        return;
      }

      context.read<AnnouncementBloc>().add(
            UpdateAnnouncementEvent(
              id: id,
              announcement: announcement,
            ),
          );
    } else {
      context.read<AnnouncementBloc>().add(
            CreateAnnouncementEvent(announcement),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocListener<AnnouncementBloc, AnnouncementState>(
      listener: (context, state) {
        if (_submitted && state is AnnouncementLoaded) {
          Navigator.pop(context);
        }

        if (_submitted && state is AnnouncementError) {
          setState(() => _submitted = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEdit ? loc.editInfo : loc.createAnnouncement,
          ),
        ),
        body: BlocBuilder<AnnouncementBloc, AnnouncementState>(
          builder: (context, state) {
            final isLoading = _submitted && state is AnnouncementLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(loc.titleEn),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: loc.enterTitleEn,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';

                        if (text.isEmpty) {
                          return loc.enterTitleEn;
                        }

                        if (text.length < 3) {
                          return 'Title must be at least 3 characters';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    Text(loc.contentEn),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _contentController,
                      minLines: 4,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: loc.enterContentEn,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';

                        if (text.isEmpty) {
                          return loc.enterContentEn;
                        }

                        if (text.length < 5) {
                          return 'Content must be at least 5 characters';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          widget.isEdit ? loc.save : loc.publishAnnouncement,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F5DA9),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: isLoading ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}