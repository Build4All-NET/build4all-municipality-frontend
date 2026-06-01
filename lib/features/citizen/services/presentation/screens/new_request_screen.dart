import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/app_text_field.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'package:baladiyati/features/citizen/services/data/models/request_submission.dart';
import 'package:baladiyati/features/citizen/services/data/services/request_service.dart';
import 'package:baladiyati/features/citizen/services/data/services/file_upload_service.dart';
import 'package:baladiyati/features/citizen/services/domain/entities/service_entity.dart';

class NewRequestScreen extends StatefulWidget {
  final ServiceEntity service;
  const NewRequestScreen({super.key, required this.service});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _requestService = RequestService();
  final _fileUploadService = FileUploadService();
  final _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _isUploading = false;
  bool _pickingLocation = false;

  double? _geoLat;
  double? _geoLng;

  final List<File> _selectedFiles = [];
  final List<String> _selectedFileNames = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final loc = AppLocalizations.of(context)!;
    setState(() => _pickingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        AppToast.show(
          context,
          message: loc.locationPermissionPermanentlyDenied,
          type: AppToastType.error,
        );
        return;
      }
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        AppToast.show(
          context,
          message: loc.locationPermissionDenied,
          type: AppToastType.error,
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _geoLat = position.latitude;
        _geoLng = position.longitude;
      });
      AppToast.show(
        context,
        message: loc.locationPicked,
        type: AppToastType.success,
      );
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        context,
        message: loc.locationPickFailed,
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _pickingLocation = false);
    }
  }

  Future<void> _pickFiles() async {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_outlined,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(loc.takePhoto),
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedFiles.add(File(picked.path));
                      _selectedFileNames.add(picked.name);
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined,
                    color: Theme.of(context).colorScheme.secondary),
                title: Text(loc.chooseFromGallery),
                onTap: () async {
                  Navigator.pop(context);
                  final picked =
                      await _imagePicker.pickMultiImage(imageQuality: 80);
                  if (picked.isNotEmpty) {
                    setState(() {
                      for (final xf in picked) {
                        _selectedFiles.add(File(xf.path));
                        _selectedFileNames.add(xf.name);
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf_outlined,
                    color: Theme.of(context).colorScheme.error),
                title: Text(loc.chooseDocument),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                    type: FileType.custom,
                    allowedExtensions: [
                      'pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png',
                    ],
                  );
                  if (result != null && result.files.isNotEmpty) {
                    setState(() {
                      for (final pf in result.files) {
                        if (pf.path != null) {
                          _selectedFiles.add(File(pf.path!));
                          _selectedFileNames.add(pf.name);
                        }
                      }
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _selectedFileNames.removeAt(index);
    });
  }

  Widget _fileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    final colors = Theme.of(context).colorScheme;
    if (ext == 'pdf') {
      return Icon(Icons.picture_as_pdf, color: colors.error, size: 36);
    } else if (['doc', 'docx'].contains(ext)) {
      return Icon(Icons.description, color: colors.primary, size: 36);
    } else {
      final idx = _selectedFileNames.indexOf(fileName);
      if (idx >= 0 && idx < _selectedFiles.length) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            _selectedFiles[idx],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        );
      }
      return Icon(Icons.insert_drive_file, color: colors.outline, size: 36);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final loc = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      List<String> uploadedUrls = [];
      if (_selectedFiles.isNotEmpty) {
        setState(() => _isUploading = true);
        uploadedUrls = await _fileUploadService.uploadFiles(_selectedFiles);
        setState(() => _isUploading = false);
      }

      await _requestService.submitRequest(
        serviceId: widget.service.id.toString(),
        submission: RequestSubmission(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          geoLat: _geoLat,
          geoLng: _geoLng,
          attachmentUrls: uploadedUrls.isEmpty ? null : uploadedUrls,
        ),
      );

      if (!mounted) return;

      AppToast.show(
        context,
        message: loc.requestSubmittedTitle,
        type: AppToastType.success,
      );

      final colors = Theme.of(context).colorScheme;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: colors.primary, size: 72),
              const SizedBox(height: 16),
              Text(
                loc.requestSubmittedTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                loc.requestSubmittedMsg,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colors.outline),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: loc.ok,
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      AppToast.show(
        context,
        message: e.toString().replaceAll('Exception:', '').trim(),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final langCode = Localizations.localeOf(context).languageCode;
    final s = widget.service;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.newRequest),
            Text(
              s.localizedName(langCode),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colors.onSurface.withOpacity(0.65)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Service info card
              if (s.slaDays != null || s.hasFees)
                _InfoCard(
                  title: loc.serviceInfo,
                  theme: theme,
                  colors: colors,
                  child: Column(
                    children: [
                      if (s.hasFees)
                        _InfoRow(
                          label: loc.feeLabel,
                          value: s.feeAmount != null
                              ? s.feeAmount!.toStringAsFixed(0)
                              : loc.free,
                          theme: theme,
                          colors: colors,
                        ),
                      if (s.hasFees && s.slaDays != null)
                        const SizedBox(height: 8),
                      if (s.slaDays != null)
                        _InfoRow(
                          label: loc.processingTime,
                          value: '${s.slaDays} ${loc.days}',
                          theme: theme,
                          colors: colors,
                        ),
                    ],
                  ),
                ),
              if (s.slaDays != null || s.hasFees) const SizedBox(height: 12),

              // Request details card
              _InfoCard(
                title: loc.requestDetails,
                theme: theme,
                colors: colors,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _titleCtrl,
                      label: loc.titleLabel,
                      hint: loc.titleHint,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? loc.fieldRequired
                              : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _descCtrl,
                      label: loc.descriptionLabel,
                      hint: loc.descriptionHint,
                      maxLines: 4,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? loc.fieldRequired
                              : null,
                    ),
                    const SizedBox(height: 12),
                    _LocationPickerButton(
                      geoLat: _geoLat,
                      geoLng: _geoLng,
                      isLoading: _pickingLocation,
                      onTap: _isLoading ? null : _pickLocation,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Attachments card
              _InfoCard(
                title: loc.requiredAttachments,
                theme: theme,
                colors: colors,
                child: Column(
                  children: [
                    if (_selectedFiles.isNotEmpty) ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedFiles.length,
                        itemBuilder: (_, i) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => _removeFile(i),
                                child:
                                    Icon(Icons.close, color: colors.error, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedFileNames[i],
                                  style: theme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: _fileIcon(_selectedFileNames[i]),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    GestureDetector(
                      onTap: _isLoading ? null : _pickFiles,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: colors.outline.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_outlined,
                                    size: 28, color: colors.outline),
                                const SizedBox(width: 8),
                                Icon(Icons.camera_alt_outlined,
                                    size: 28, color: colors.outline),
                                const SizedBox(width: 8),
                                Icon(Icons.picture_as_pdf_outlined,
                                    size: 28, color: colors.outline),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFiles.isEmpty
                                  ? loc.tapToUpload
                                  : '${_selectedFiles.length} ${loc.filesSelected}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: _selectedFiles.isEmpty
                                    ? colors.onSurface
                                    : colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_isUploading) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(loc.uploadingFiles,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: colors.outline)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              PrimaryButton(
                label: loc.submitRequest,
                onPressed: _submit,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final ThemeData theme;
  final ColorScheme colors;

  const _InfoCard({
    required this.title,
    required this.child,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
              color: colors.shadow.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme colors;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                theme.textTheme.bodySmall?.copyWith(color: colors.outline)),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _LocationPickerButton extends StatelessWidget {
  final double? geoLat;
  final double? geoLng;
  final bool isLoading;
  final VoidCallback? onTap;

  const _LocationPickerButton({
    this.geoLat,
    this.geoLng,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final hasPick = geoLat != null && geoLng != null;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: hasPick
              ? colors.primaryContainer.withOpacity(0.35)
              : colors.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasPick
                ? colors.primary.withOpacity(0.4)
                : colors.outline.withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasPick ? colors.primary : colors.outline.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: hasPick ? colors.onPrimary : colors.onSurfaceVariant,
                      ),
                    )
                  : Icon(
                      hasPick ? Icons.location_on : Icons.location_on_outlined,
                      size: 18,
                      color: hasPick ? colors.onPrimary : colors.onSurfaceVariant,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.locationLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasPick
                        ? '${loc.lat}: ${geoLat!.toStringAsFixed(5)},  ${loc.lng}: ${geoLng!.toStringAsFixed(5)}'
                        : loc.pickLocationHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hasPick ? colors.onSurface : colors.onSurfaceVariant,
                      fontWeight: hasPick ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLoading)
              Icon(
                Icons.my_location,
                size: 18,
                color: hasPick ? colors.primary : colors.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
