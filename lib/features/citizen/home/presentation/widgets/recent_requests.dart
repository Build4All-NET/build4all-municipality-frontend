// lib/features/citizen/home/presentation/widgets/recent_requests.dart

import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

class RecentRequestItem {
  final String id;
  final String nameAr;
  final String status;
  final String date;

  const RecentRequestItem({
    required this.id,
    required this.nameAr,
    required this.status,
    required this.date,
  });
}

class RecentRequestsSection extends StatelessWidget {
  final List<RecentRequestItem> requests;
  final VoidCallback onViewAll;
  final Function(RecentRequestItem) onRequestTap;

  const RecentRequestsSection({
    super.key,
    required this.requests,
    required this.onViewAll,
    required this.onRequestTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                l10n.viewAll,
                style: const TextStyle(
                    color: Color(0xFF2F6FED),
                    fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              l10n.recentRequests,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Request cards
        ...requests.map((request) => _RequestCard(
              request: request,
              onTap: () => onRequestTap(request),
            )),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RecentRequestItem request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isWaitingPayment = request.status == 'waiting_payment';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Date + status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isWaitingPayment
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFFFFDE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isWaitingPayment ? 'بانتظار الدفع' : 'قيد التدقيق',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isWaitingPayment
                          ? Colors.orange.shade700
                          : Colors.yellow.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(request.date,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),

            // Request name
            Text(
              request.nameAr,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
