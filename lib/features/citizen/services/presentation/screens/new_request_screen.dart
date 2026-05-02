// lib/features/citizen/services/presentation/screens/new_request_screen.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/features/citizen/services/data/models/request_submission.dart';
import 'package:baladiyati/features/citizen/services/data/services/request_service.dart';
import 'services_by_category_screen.dart';

class NewRequestScreen extends StatefulWidget {
  final ServiceItem service;
  const NewRequestScreen({super.key, required this.service});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  final _requestService = RequestService();

  bool _isLoading = false;
  int _fileCount = 0;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _requestService.submitRequest(
        serviceId: widget.service.id,
        submission: RequestSubmission(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          addressText: _locationCtrl.text.trim().isEmpty
              ? null
              : _locationCtrl.text.trim(),
        ),
      );

      if (!mounted) return;

      // ── Green success dialog ──────────────────────────────────────────────
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
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 72,
              ),
              const SizedBox(height: 16),
              const Text(
                'تم تقديم الطلب بنجاح!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'سيتم مراجعة طلبك من قبل البلدية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'حسناً',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      // ─────────────────────────────────────────────────────────────────────
    } catch (e) {
      if (!mounted) return;

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
    final l10n = AppLocalizations.of(context)!;
    final s = widget.service;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.newRequest,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          s.nameAr,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Service info card
                      _card(
                        title: l10n.serviceInfo,
                        child: Column(
                          children: [
                            _infoRow(
                              label: l10n.feeLabel,
                              value: s.fee == 0
                                  ? l10n.free
                                  : '${_fmt(s.fee)} ${l10n.lbp}',
                            ),
                            const SizedBox(height: 8),
                            _infoRow(
                              label: l10n.processingTime,
                              value: '${s.processingDays} ${l10n.days}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Request details card
                      _card(
                        title: l10n.requestDetails,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _fieldLabel(l10n.titleLabel),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _titleCtrl,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: l10n.titleHint,
                                filled: true,
                                fillColor: const Color(0xFFF3F4F6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? l10n.fieldRequired
                                      : null,
                            ),
                            const SizedBox(height: 12),

                            _fieldLabel(l10n.descriptionLabel),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _descCtrl,
                              textAlign: TextAlign.right,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: l10n.descriptionHint,
                                filled: true,
                                fillColor: const Color(0xFFF3F4F6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? l10n.fieldRequired
                                      : null,
                            ),
                            const SizedBox(height: 12),

                            _fieldLabel(l10n.locationLabel),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _locationCtrl,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: l10n.locationHint,
                                prefixIcon: const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFFF3F4F6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Attachments card
                      _card(
                        title: l10n.requiredAttachments,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ...s.requiredDocs.map((doc) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.end,
                                    children: [
                                      Text(doc,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey)),
                                      const SizedBox(width: 6),
                                      const Text('•',
                                          style: TextStyle(
                                              color: Colors.grey)),
                                    ],
                                  ),
                                )),
                            const SizedBox(height: 12),

                            GestureDetector(
                              onTap: () =>
                                  setState(() => _fileCount++),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.shade300),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.upload_outlined,
                                            size: 32,
                                            color: Colors.grey),
                                        SizedBox(width: 8),
                                        Icon(
                                            Icons.camera_alt_outlined,
                                            size: 32,
                                            color: Colors.grey),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(l10n.tapToUpload,
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text(l10n.pdfOrImages,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey)),
                                    if (_fileCount > 0) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        '$_fileCount ${l10n.filesSelected}',
                                        style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight:
                                                FontWeight.w500),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(l10n.submitRequest,
                                  style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _fieldLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500));

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
