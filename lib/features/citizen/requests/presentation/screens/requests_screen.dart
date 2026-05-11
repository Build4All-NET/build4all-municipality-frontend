// lib/features/citizen/requests/presentation/screens/requests_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/common/widgets/app_search_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_bloc.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_state.dart';
import 'package:baladiyati/features/citizen/requests/data/models/request_model.dart';
import 'request_details_screen.dart';

enum RequestStatus {
  submitted,
  underReview,
  waitingPayment,
  approved,
  inField,
  delivered,
}

class RequestItem {
  final String id;
  final String nameAr;
  final String number;
  final RequestStatus status;
  final String date;

  const RequestItem({
    required this.id,
    required this.nameAr,
    required this.number,
    required this.status,
    required this.date,
  });
}

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  RequestStatus? _filterStatus;

  // Track previous error to avoid showing toast multiple times
  String? _lastShownError;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  RequestStatus _toEnum(String raw) {
    switch (raw.toLowerCase()) {
      case 'submitted':        return RequestStatus.submitted;
      case 'under_review':
      case 'underreview':
      case 'review':           return RequestStatus.underReview;
      case 'waiting_payment':
      case 'waitingpayment':
      case 'payment':          return RequestStatus.waitingPayment;
      case 'approved':         return RequestStatus.approved;
      case 'in_field':
      case 'infield':
      case 'field':            return RequestStatus.inField;
      case 'delivered':
      case 'completed':        return RequestStatus.delivered;
      default:                 return RequestStatus.submitted;
    }
  }

  List<RequestItem> _toItems(List<RequestModel> models) =>
      models.map((r) => RequestItem(
            id: r.id,
            nameAr: r.nameAr,
            number: r.number,
            status: _toEnum(r.status),
            date: r.date,
          )).toList();

  List<RequestItem> _filtered(List<RequestItem> items) =>
      items.where((r) {
        final matchSearch = _query.isEmpty ||
            r.nameAr.contains(_query) ||
            r.number.toLowerCase().contains(_query.toLowerCase());
        final matchStatus =
            _filterStatus == null || r.status == _filterStatus;
        return matchSearch && matchStatus;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<RequestsBloc, RequestsState>(
      // Show error as toast, not inline red text
      listener: (context, state) {
        if (state.errorMessage != null &&
            state.errorMessage != _lastShownError) {
          _lastShownError = state.errorMessage;
          AppToast.show(
            context,
            message: state.errorMessage!,
            type: AppToastType.error,
          );
        }
      },
      builder: (context, state) {
        final items = _filtered(_toItems(state.requests));

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.myRequests,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),

                      //  AppSearchField replaces raw TextField
                      AppSearchField(
                        controller: _searchCtrl,
                        hint: l10n.searchRequest,
                        onChanged: (v) => setState(() => _query = v),
                        onClear: _query.isEmpty
                            ? null
                            : () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.filter_list,
                              color: Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<RequestStatus?>(
                                  value: _filterStatus,
                                  isExpanded: true,
                                  items: [
                                    DropdownMenuItem(
                                        value: null,
                                        child: Text(l10n.filterAll)),
                                    DropdownMenuItem(
                                        value: RequestStatus.submitted,
                                        child: Text(l10n.statusSubmitted)),
                                    DropdownMenuItem(
                                        value: RequestStatus.underReview,
                                        child: Text(l10n.statusUnderReview)),
                                    DropdownMenuItem(
                                        value: RequestStatus.waitingPayment,
                                        child: Text(l10n.statusWaitingPayment)),
                                    DropdownMenuItem(
                                        value: RequestStatus.approved,
                                        child: Text(l10n.statusApproved)),
                                    DropdownMenuItem(
                                        value: RequestStatus.delivered,
                                        child: Text(l10n.statusDelivered)),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _filterStatus = v),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── List ─────────────────────────────────────────
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.description_outlined,
                                      size: 64, color: Colors.grey),
                                  const SizedBox(height: 12),
                                  Text(l10n.noRequests,
                                      style: const TextStyle(
                                          color: Colors.grey)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: items.length,
                              itemBuilder: (_, i) {
                                final r = items[i];
                                return _RequestCard(
                                  item: r,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          RequestDetailsScreen(request: r),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestItem item;
  final VoidCallback onTap;
  const _RequestCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadgeWidget(status: item.status),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item.number,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                    Text(item.nameAr,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'تاريخ التقديم: ${item.date}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBadgeWidget extends StatelessWidget {
  final RequestStatus status;
  const StatusBadgeWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: config.text),
      ),
    );
  }

  _StatusConfig _config(RequestStatus s) {
    switch (s) {
      case RequestStatus.submitted:
        return _StatusConfig('مقدمة',
            const Color(0xFFE3F2FD), const Color(0xFF1565C0));
      case RequestStatus.underReview:
        return _StatusConfig('قيد التدقيق',
            const Color(0xFFFFFDE7), const Color(0xFFF9A825));
      case RequestStatus.waitingPayment:
        return _StatusConfig('بانتظار الدفع',
            const Color(0xFFFFF3E0), Colors.orange);
      case RequestStatus.approved:
        return _StatusConfig('موافق عليها',
            const Color(0xFFE8F5E9), Colors.green);
      case RequestStatus.inField:
        return _StatusConfig('بالكشف',
            const Color(0xFFEDE7F6), const Color(0xFF6A1B9A));
      case RequestStatus.delivered:
        return _StatusConfig('مستلمة',
            const Color(0xFFE0F7FA), const Color(0xFF00838F));
    }
  }
}

class _StatusConfig {
  final String label;
  final Color bg;
  final Color text;
  const _StatusConfig(this.label, this.bg, this.text);
}