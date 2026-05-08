// lib/features/citizen/services/presentation/screens/new_request_screen.dart

import 'dart:io';

import 'package:baladiyati/common/widgets/app_text_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/core/config/app_sizes.dart';
import 'package:baladiyati/features/citizen/services/data/models/request_submission.dart';
import 'package:baladiyati/features/citizen/services/data/services/file_upload_service.dart';
import 'package:baladiyati/features/citizen/services/data/services/request_service.dart';
import 'package:baladiyati/features/citizen/services/domain/entities/citizen_service_entity.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewRequestScreen extends StatefulWidget {
  final CitizenServiceEntity service;

  const NewRequestScreen({
    super.key,
    required this.service,
  });

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();

  final RequestService _requestService = RequestService();
  final FileUploadService _fileUploadService = FileUploadService();
  final ImagePicker _imagePicker = ImagePicker();

  final List<File> _selectedFiles = [];
  final List<String> _selectedFileNames = [];

  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.paddingSmall,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PickerTile(
                  icon: Icons.camera_alt_outlined,
                  iconColor: cs.primary,
                  title: l10n.takePhoto,
                  onTap: () async {
                    Navigator.pop(context);

                    final picked = await _imagePicker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );

                    if (picked == null) return;

                    setState(() {
                      _selectedFiles.add(File(picked.path));
                      _selectedFileNames.add(picked.name);
                    });
                  },
                ),
                _PickerTile(
                  icon: Icons.photo_library_outlined,
                  iconColor: cs.tertiary,
                  title: l10n.chooseImagesFromGallery,
                  onTap: () async {
                    Navigator.pop(context);

                    final picked = await _imagePicker.pickMultiImage(
                      imageQuality: 80,
                    );

                    if (picked.isEmpty) return;

                    setState(() {
                      for (final image in picked) {
                        _selectedFiles.add(File(image.path));
                        _selectedFileNames.add(image.name);
                      }
                    });
                  },
                ),
                _PickerTile(
                  icon: Icons.picture_as_pdf_outlined,
                  iconColor: cs.error,
                  title: l10n.choosePdfOrDocument,
                  onTap: () async {
                    Navigator.pop(context);

                    final result = await FilePicker.platform.pickFiles(
                      allowMultiple: true,
                      type: FileType.custom,
                      allowedExtensions: const [
                        'pdf',
                        'doc',
                        'docx',
                        'jpg',
                        'jpeg',
                        'png',
                      ],
                    );

                    if (result == null || result.files.isEmpty) return;

                    setState(() {
                      for (final file in result.files) {
                        if (file.path != null) {
                          _selectedFiles.add(File(file.path!));
                          _selectedFileNames.add(file.name);
                        }
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _selectedFileNames.removeAt(index);
    });
  }

  Widget _filePreview(String fileName) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final ext = fileName.split('.').last.toLowerCase();

    if (ext == 'pdf') {
      return Icon(
        Icons.picture_as_pdf,
        color: cs.error,
        size: AppSizes.iconMedium,
      );
    }

    if (ext == 'doc' || ext == 'docx') {
      return Icon(
        Icons.description,
        color: cs.primary,
        size: AppSizes.iconMedium,
      );
    }

    final index = _selectedFileNames.indexOf(fileName);

    if (index >= 0 && index < _selectedFiles.length) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Image.file(
          _selectedFiles[index],
          width: AppSizes.iconLarge * 0.70,
          height: AppSizes.iconLarge * 0.70,
          fit: BoxFit.cover,
        ),
      );
    }

    return Icon(
      Icons.insert_drive_file,
      color: cs.onSurfaceVariant,
      size: AppSizes.iconMedium,
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      List<String> uploadedUrls = [];

      if (_selectedFiles.isNotEmpty) {
        setState(() => _isUploading = true);

        uploadedUrls = await _fileUploadService.uploadFiles(_selectedFiles);

        if (!mounted) return;
        setState(() => _isUploading = false);
      }

      await _requestService.submitRequest(
        serviceId: widget.service.id.toString(),
        submission: RequestSubmission(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          addressText: _locationCtrl.text.trim().isEmpty
              ? null
              : _locationCtrl.text.trim(),
          attachmentUrls: uploadedUrls.isEmpty ? null : uploadedUrls,
        ),
      );

      if (!mounted) return;

      AppToast.show(
        context,
        message: l10n.requestSubmitted,
        type: AppToastType.success,
      );

      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isUploading = false);

      AppToast.show(
        context,
        message: error.toString().replaceAll('Exception:', '').trim(),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatAmount(double amount) {
    final value = amount.round();

    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final service = widget.service;
    final serviceName = service.localizedName(isArabic: isArabic);

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: cs.surface,
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingSmall,
                AppSizes.paddingSmall,
                AppSizes.paddingMedium,
                AppSizes.paddingSmall,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_forward,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall / 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.newRequest,
                          textAlign: TextAlign.right,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall / 2),
                        Text(
                          serviceName,
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _SectionCard(
                        title: l10n.serviceInfo,
                        child: Column(
                          children: [
                            _InfoRow(
                              label: l10n.feeLabel,
                              value: service.hasFees && service.feeAmount > 0
                                  ? '${_formatAmount(service.feeAmount)} ${l10n.lbp}'
                                  : l10n.free,
                            ),
                            const SizedBox(height: AppSizes.paddingSmall),
                            _InfoRow(
                              label: l10n.processingTime,
                              value: '${service.slaDays} ${l10n.days}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      _SectionCard(
                        title: l10n.requestDetails,
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _titleCtrl,
                              label: l10n.titleLabel,
                              hint: l10n.titleHint,
                              textAlign: TextAlign.right,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.fieldRequired;
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.paddingMedium),
                            AppTextField(
                              controller: _descCtrl,
                              label: l10n.descriptionLabel,
                              hint: l10n.descriptionHint,
                              textAlign: TextAlign.right,
                              maxLines: 4,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.fieldRequired;
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: AppSizes.paddingMedium),
                            AppTextField(
                              controller: _locationCtrl,
                              label: l10n.locationLabel,
                              hint: l10n.locationHint,
                              icon: Icons.location_on_outlined,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      _SectionCard(
                        title: l10n.requiredAttachments,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (_selectedFiles.isNotEmpty) ...[
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _selectedFiles.length,
                                separatorBuilder: (_, __) {
                                  return const SizedBox(
                                    height: AppSizes.paddingSmall,
                                  );
                                },
                                itemBuilder: (context, index) {
                                  return _SelectedFileTile(
                                    fileName: _selectedFileNames[index],
                                    preview: _filePreview(
                                      _selectedFileNames[index],
                                    ),
                                    onRemove: () => _removeFile(index),
                                  );
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingMedium),
                            ],
                            _UploadBox(
                              isDisabled: _isLoading,
                              selectedCount: _selectedFiles.length,
                              onTap: _pickFiles,
                            ),
                            if (_isUploading) ...[
                              const SizedBox(height: AppSizes.paddingMedium),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: AppSizes.iconSmall,
                                    height: AppSizes.iconSmall,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.paddingSmall),
                                  Text(
                                    l10n.uploadingFiles,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      PrimaryButton(
                        label: l10n.submitRequest,
                        onPressed: _submit,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: cs.outline.withOpacity(0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.right,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SelectedFileTile extends StatelessWidget {
  final String fileName;
  final Widget preview;
  final VoidCallback onRemove;

  const _SelectedFileTile({
    required this.fileName,
    required this.preview,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: cs.outline.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.close,
              color: cs.error,
              size: AppSizes.iconSmall,
            ),
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          Expanded(
            child: Text(
              fileName,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          SizedBox(
            width: AppSizes.iconLarge * 0.70,
            height: AppSizes.iconLarge * 0.70,
            child: Center(
              child: preview,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final bool isDisabled;
  final int selectedCount;
  final VoidCallback onTap;

  const _UploadBox({
    required this.isDisabled,
    required this.selectedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        decoration: BoxDecoration(
          border: Border.all(
            color: cs.outline.withOpacity(0.35),
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          color: cs.surfaceVariant.withOpacity(0.20),
        ),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSizes.paddingSmall,
              children: [
                Icon(
                  Icons.upload_outlined,
                  size: AppSizes.iconMedium,
                  color: cs.onSurfaceVariant,
                ),
                Icon(
                  Icons.camera_alt_outlined,
                  size: AppSizes.iconMedium,
                  color: cs.onSurfaceVariant,
                ),
                Icon(
                  Icons.picture_as_pdf_outlined,
                  size: AppSizes.iconMedium,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              selectedCount == 0
                  ? l10n.tapToUpload
                  : '$selectedCount ${l10n.filesSelected}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: selectedCount == 0 ? cs.onSurface : cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall / 2),
            Text(
              l10n.pdfOrImages,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}