// lib/features/citizen/requests/presentation/screens/request_details_screen.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'requests_screen.dart';

class _TimelineStep {
  final RequestStatus status;
  final String date;
  final bool completed;
  const _TimelineStep(
      {required this.status, required this.date, required this.completed});
}

class RequestDetailsScreen extends StatelessWidget {
  final RequestItem request;
  const RequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final timeline = [
      _TimelineStep(
          status: RequestStatus.submitted,
          date: '١٧-٠٣-٢٠٢٦',
          completed: true),
      _TimelineStep(
          status: RequestStatus.underReview,
          date: '١٨-٠٣-٢٠٢٦',
          completed: true),
      _TimelineStep(
          status: RequestStatus.approved,
          date: '١٩-٠٣-٢٠٢٦',
          completed: true),
      _TimelineStep(
          status: RequestStatus.waitingPayment,
          date: '١٩-٠٣-٢٠٢٦',
          completed: request.status == RequestStatus.waitingPayment ||
              request.status == RequestStatus.delivered),
      _TimelineStep(
          status: RequestStatus.delivered,
          date: '',
          completed: request.status == RequestStatus.delivered),
    ];

    final completedCount = timeline.where((t) => t.completed).length;
    final progress = completedCount / timeline.length;

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
                        Text(
                          request.number,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          request.nameAr,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
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
                    // Progress card
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
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                              Text(
                                l10n.progress,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF1E3A5F)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Timeline card
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.timeline,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(timeline.length, (i) {
                            final step = timeline[i];
                            final isLast = i == timeline.length - 1;
                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // Left: connector line
                                Column(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: step.completed
                                            ? Colors.green
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    if (!isLast)
                                      Container(
                                        width: 2,
                                        height: 40,
                                        color: step.completed
                                            ? Colors.green
                                            : Colors.grey.shade300,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // Right: status + date
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        StatusBadgeWidget(
                                            status: step.status),
                                        if (step.date.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(
                                                    top: 4),
                                            child: Text(
                                              step.date,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Details card
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.details,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          _detailRow(
                            icon: Icons.description_outlined,
                            label: l10n.descriptionLabel,
                            value:
                                'طلب استخراج براءة ذمة بلدية للعقار رقم ١٢٣٤',
                          ),
                          const SizedBox(height: 10),
                          _detailRow(
                            icon: Icons.calendar_today_outlined,
                            label: l10n.submissionDate,
                            value: request.date,
                          ),
                        ],
                      ),
                    ),

                    // Payment card (if waiting)
                    if (request.status ==
                        RequestStatus.waitingPayment) ...[
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
                            Text(
                              l10n.amountDue,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
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
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF1E3A5F),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () =>
                                    Navigator.pop(context),
                                child: Text(l10n.payNow),
                              ),
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

  Widget _detailRow(
      {required IconData icon,
      required String label,
      required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
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
