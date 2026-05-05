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

  void _showMessage(String message, {bool isError = false}) {
    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : null,
      ),
    );
  }

  String? _validateTitle(String? value) {
    final loc = AppLocalizations.of(context)!;
    final text = value?.trim() ?? '';

    if (text.isEmpty) return loc.fieldRequired;

    if (text.length < 3) return loc.titleMinLength;

    return null;
  }

  String? _validateContent(String? value) {
    final loc = AppLocalizations.of(context)!;
    final text = value?.trim() ?? '';

    if (text.isEmpty) return loc.fieldRequired;

    if (text.length < 5) return loc.contentMinLength;

    return null;
  }

  void _submit() {
    final loc = AppLocalizations.of(context)!;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final announcement = Announcement(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );

    setState(() {
      _submitted = true;
    });

    if (widget.isEdit) {
      final id = widget.announcement?.id;

      if (id == null) {
        setState(() {
          _submitted = false;
        });
        _showMessage(loc.missingAnnouncementId, isError: true);
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocListener<AnnouncementBloc, AnnouncementState>(
      listener: (context, state) {
        if (!_submitted) return;

        if (state is AnnouncementLoaded) {
          _showMessage(loc.announcementSaved);
          Navigator.pop(context);
        }

        if (state is AnnouncementError) {
          setState(() {
            _submitted = false;
          });
          _showMessage(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            widget.isEdit ? loc.editAnnouncement : loc.createAnnouncement,
          ),
        ),
        body: BlocBuilder<AnnouncementBloc, AnnouncementState>(
          builder: (context, state) {
            final isLoading = _submitted && state is AnnouncementLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _FormHeader(
                      title: widget.isEdit
                          ? loc.editAnnouncement
                          : loc.createAnnouncement,
                      subtitle: widget.isEdit
                          ? loc.announcementEditHint
                          : loc.announcementCreateHint,
                    ),

                    const SizedBox(height: 16),

                    _InputField(
                      label: loc.announcementTitle,
                      hint: loc.enterAnnouncementTitle,
                      controller: _titleController,
                      icon: Icons.title_outlined,
                      validator: _validateTitle,
                      enabled: !isLoading,
                    ),

                    _InputField(
                      label: loc.announcementContent,
                      hint: loc.enterAnnouncementContent,
                      controller: _contentController,
                      icon: Icons.article_outlined,
                      minLines: 5,
                      maxLines: 9,
                      validator: _validateContent,
                      enabled: !isLoading,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: isLoading
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onPrimary,
                                ),
                              )
                            : const Icon(Icons.campaign_outlined),
                        label: Text(
                          widget.isEdit ? loc.save : loc.publishAnnouncement,
                        ),
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

class _FormHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FormHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.primary.withOpacity(0.14),
            child: Icon(
              Icons.campaign_outlined,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.66),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?) validator;
  final int minLines;
  final int maxLines;
  final bool enabled;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        enabled: enabled,
        validator: validator,
        textInputAction:
            maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colors.outline.withOpacity(0.22),
            ),
          ),
        ),
      ),
    );
  }
}