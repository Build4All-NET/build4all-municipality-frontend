// lib/features/citizen/requests/presentation/screens/request_details_screen.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/common/widgets/primary_button.dart';
import 'requests_screen.dart';

class RequestDetailsScreen extends StatelessWidget {
  final RequestItem request;
  const RequestDetailsScreen({super.key, required this.request});

  // ── Timeline progression order ────────────────────────────────────────────
  // Each step shows as completed if current status has passed it
  static const List<_StepDef> _steps = [
    _StepDef(RequestStatus.submitted,        'مقدمة'),
    _StepDef(RequestStatus.underReview,      'قيد المراجعة'),
    _StepDef(RequestStatus.inProgress,       'قيد التنفيذ'),
    _StepDef(RequestStatus.approved,         'موافق عليها'),
    _StepDef(RequestStatus.taxPaid,          'تم الدفع'),
    _StepDef(RequestStatus.completed,        'مكتملة'),
  ];

  // The "weight" of each status in the flow
  static int _statusOrder(RequestStatus s) {
    switch (s) {
      case RequestStatus.draft:             return 0;
      case RequestStatus.submitted:         return 1;
      case RequestStatus.underReview:       return 2;
      case RequestStatus.documentsMissing:  return 2; // stays at review level
      case RequestStatus.inProgress:        return 3;
      case RequestStatus.approved:          return 4;
      case RequestStatus.taxPaid:           return 5;
      case RequestStatus.taxRejected:       return 5;
      case RequestStatus.completed:         return 6;
      case RequestStatus.rejected:          return 6;
      case RequestStatus.cancelled:         return 6;
    }
  }

  bool _isTerminal() =>
      request.status == RequestStatus.completed ||
      request.status == RequestStatus.rejected ||
      request.status == RequestStatus.cancelled ||
      request.status == RequestStatus.taxRejected;

  bool _isNegativeEnd() =>
      request.status == RequestStatus.rejected ||
      request.status == RequestStatus.cancelled ||
      request.status == RequestStatus.taxRejected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentOrder = _statusOrder(request.status);

    // Calculate progress
    final completedSteps = _steps
        .where((s) => _statusOrder(s.status) <= currentOrder)
        .length;
    final progress = _isNegativeEnd()
        ? completedSteps / _steps.length
        : completedSteps / _steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
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
                        Text(request.number,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                        Text(request.nameAr,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadgeWidget(status: request.status),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    // ── Special state banners ─────────────────
                    if (request.status == RequestStatus.documentsMissing)
                      _banner(
                        icon: Icons.folder_off_outlined,
                        title: 'وثائق ناقصة',
                        message: 'يرجى مراجعة البلدية لتقديم الوثائق المطلوبة',
                        color: Colors.red,
                        bg: const Color(0xFFFFEBEE),
                      ),

                    if (request.status == RequestStatus.rejected)
                      _banner(
                        icon: Icons.cancel_outlined,
                        title: 'تم رفض الطلب',
                        message: 'تم رفض طلبك من قبل رئيس البلدية',
                        color: const Color(0xFFC62828),
                        bg: const Color(0xFFFFEBEE),
                      ),

                    if (request.status == RequestStatus.taxRejected)
                      _banner(
                        icon: Icons.money_off_outlined,
                        title: 'تم رفض الدفع',
                        message: 'تم رفض الدفع الضريبي. يرجى مراجعة البلدية',
                        color: Colors.red,
                        bg: const Color(0xFFFFEBEE),
                      ),

                    if (request.status == RequestStatus.cancelled)
                      _banner(
                        icon: Icons.block_outlined,
                        title: 'تم إلغاء الطلب',
                        message: 'تم إلغاء هذا الطلب',
                        color: Colors.grey,
                        bg: const Color(0xFFF5F5F5),
                      ),

                    if (request.status == RequestStatus.completed)
                      _banner(
                        icon: Icons.check_circle_outline,
                        title: 'مكتمل',
                        message: 'تم إنجاز طلبك بنجاح',
                        color: const Color(0xFF2E7D32),
                        bg: const Color(0xFFE8F5E9),
                      ),

                    // ── Progress card ─────────────────────────
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(progress * 100).round()}%',
                                style: TextStyle(
                                    color: cs.outline, fontSize: 13),
                              ),
                              const Text('التقدم',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _isNegativeEnd() ? Colors.red : cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Timeline card ─────────────────────────
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('مراحل الطلب',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),

                          ...List.generate(_steps.length, (i) {
                            final step = _steps[i];
                            final stepOrder = _statusOrder(step.status);
                            final isDone = stepOrder <= currentOrder &&
                                !_isNegativeEnd();
                            final isCurrent =
                                step.status == request.status;
                            final isLast = i == _steps.length - 1;

                            // For negative end, color differently
                            final dotColor = _isNegativeEnd() && isCurrent
                                ? Colors.red
                                : isDone
                                    ? cs.primary
                                    : Colors.grey.shade300;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Connector
                                Column(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: dotColor,
                                        border: isCurrent
                                            ? Border.all(
                                                color: dotColor,
                                                width: 2)
                                            : null,
                                      ),
                                      child: isDone && !isCurrent
                                          ? Icon(Icons.check,
                                              size: 8,
                                              color: cs.onPrimary)
                                          : null,
                                    ),
                                    if (!isLast)
                                      Container(
                                        width: 2,
                                        height: 44,
                                        color: isDone
                                            ? cs.primary
                                            : Colors.grey.shade200,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // Label
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          step.label,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isCurrent
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isDone
                                                ? cs.onSurface
                                                : Colors.grey,
                                          ),
                                        ),
                                        if (isCurrent)
                                          StatusBadgeWidget(
                                              status: request.status),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),

                          // Show rejected/cancelled as extra step at end
                          if (_isNegativeEnd()) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 8, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      StatusBadgeWidget(
                                          status: request.status),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Details card ──────────────────────────
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('تفاصيل الطلب',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          if (request.title != null &&
                              request.title!.isNotEmpty)
                            _detailRow(
                              icon: Icons.title_outlined,
                              label: 'العنوان',
                              value: request.title!,
                            ),
                          if (request.description != null &&
                              request.description!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _detailRow(
                              icon: Icons.description_outlined,
                              label: 'الوصف',
                              value: request.description!,
                            ),
                          ],
                          const SizedBox(height: 10),
                          _detailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'تاريخ التقديم',
                            value: request.date,
                          ),
                          if (request.updatedAt != null &&
                              request.updatedAt!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _detailRow(
                              icon: Icons.update_outlined,
                              label: 'آخر تحديث',
                              value: request.updatedAt!,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── Tax payment card ──────────────────────
                    if (request.status == RequestStatus.approved ||
                        request.status == RequestStatus.taxPaid) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8F0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.orange.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('الرسوم المستحقة',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey)),
                            const SizedBox(height: 4),
                            const Text(
                              '5,000 ل.ل',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 14),
                            request.status == RequestStatus.taxPaid
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      '✓ تم الدفع',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : PrimaryButton(
                                    label: 'ادفع الآن',
                                    onPressed: () {},
                                  ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _banner({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
    required Color bg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14)),
              const SizedBox(height: 4),
              Text(message,
                  style: TextStyle(color: color.withOpacity(0.8),
                      fontSize: 12)),
            ],
          ),
          const SizedBox(width: 10),
          Icon(icon, color: color, size: 28),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
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
      child: child,
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13)),
          ],
        ),
        const SizedBox(width: 8),
        Icon(icon, color: Colors.grey, size: 18),
      ],
    );
  }
}

class _StepDef {
  final RequestStatus status;
  final String label;
  const _StepDef(this.status, this.label);
}