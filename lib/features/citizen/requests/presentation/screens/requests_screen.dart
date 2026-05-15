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
  draft,
  submitted,
  underReview,
  documentsMissing,
  inProgress,
  approved,
  rejected,
  completed,
  cancelled,
  taxPaid,
  taxRejected,
}

class RequestItem {
  final String id;
  final String nameAr;
  final String number;
  final RequestStatus status;
  final String date;
  final String? title;
  final String? description;
  final String? updatedAt;

  const RequestItem({
    required this.id,
    required this.nameAr,
    required this.number,
    required this.status,
    required this.date,
    this.title,
    this.description,
    this.updatedAt,
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
  String? _lastShownError;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static RequestStatus toEnum(String raw) {
    switch (raw.toUpperCase()) {
      case 'DRAFT':             return RequestStatus.draft;
      case 'SUBMITTED':         return RequestStatus.submitted;
      case 'UNDER_REVIEW':      return RequestStatus.underReview;
      case 'DOCUMENTS_MISSING': return RequestStatus.documentsMissing;
      case 'IN_PROGRESS':       return RequestStatus.inProgress;
      case 'APPROVED':          return RequestStatus.approved;
      case 'REJECTED':          return RequestStatus.rejected;
      case 'COMPLETED':         return RequestStatus.completed;
      case 'CANCELLED':         return RequestStatus.cancelled;
      case 'TAX_PAID':          return RequestStatus.taxPaid;
      case 'TAX_REJECTED':      return RequestStatus.taxRejected;
      default:                  return RequestStatus.submitted;
    }
  }

  List<RequestItem> _toItems(List<RequestModel> models) =>
      models.map((r) => RequestItem(
            id: r.id,
            nameAr: r.nameAr,
            number: r.number,
            status: toEnum(r.status),
            date: r.date,
            title: r.title,
            description: r.description,
            updatedAt: r.updatedAt,
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
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

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
                                        value: RequestStatus.draft,
                                        child: Text(_statusLabel(RequestStatus.draft))),
                                    DropdownMenuItem(
                                        value: RequestStatus.submitted,
                                        child: Text(_statusLabel(RequestStatus.submitted))),
                                    DropdownMenuItem(
                                        value: RequestStatus.underReview,
                                        child: Text(_statusLabel(RequestStatus.underReview))),
                                    DropdownMenuItem(
                                        value: RequestStatus.documentsMissing,
                                        child: Text(_statusLabel(RequestStatus.documentsMissing))),
                                    DropdownMenuItem(
                                        value: RequestStatus.inProgress,
                                        child: Text(_statusLabel(RequestStatus.inProgress))),
                                    DropdownMenuItem(
                                        value: RequestStatus.approved,
                                        child: Text(_statusLabel(RequestStatus.approved))),
                                    DropdownMenuItem(
                                        value: RequestStatus.rejected,
                                        child: Text(_statusLabel(RequestStatus.rejected))),
                                    DropdownMenuItem(
                                        value: RequestStatus.completed,
                                        child: Text(_statusLabel(RequestStatus.completed))),
                                    DropdownMenuItem(
                                        value: RequestStatus.cancelled,
                                        child: Text(_statusLabel(RequestStatus.cancelled))),
                                    DropdownMenuItem(
                                        value: RequestStatus.taxPaid,
                                        child: Text(_statusLabel(RequestStatus.taxPaid))),
                                    DropdownMenuItem(
                                        value: RequestStatus.taxRejected,
                                        child: Text(_statusLabel(RequestStatus.taxRejected))),
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

// ── Status label ──────────────────────────────────────────────────────────────
String _statusLabel(RequestStatus s) {
  switch (s) {
    case RequestStatus.draft:             return 'مسودة';
    case RequestStatus.submitted:         return 'مقدمة';
    case RequestStatus.underReview:       return 'قيد المراجعة';
    case RequestStatus.documentsMissing:  return 'وثائق ناقصة';
    case RequestStatus.inProgress:        return 'قيد التنفيذ';
    case RequestStatus.approved:          return 'موافق عليها';
    case RequestStatus.rejected:          return 'مرفوضة';
    case RequestStatus.completed:         return 'مكتملة';
    case RequestStatus.cancelled:         return 'ملغاة';
    case RequestStatus.taxPaid:           return 'تم دفع الضريبة';
    case RequestStatus.taxRejected:       return 'رُفض الدفع';
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
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

// ── Status Badge ──────────────────────────────────────────────────────────────
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
        _statusLabel(status),
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: config.text),
      ),
    );
  }

  _StatusConfig _config(RequestStatus s) {
    switch (s) {
      case RequestStatus.draft:
        return _StatusConfig(const Color(0xFFF5F5F5), Colors.grey);
      case RequestStatus.submitted:
        return _StatusConfig(const Color(0xFFE3F2FD), const Color(0xFF1565C0));
      case RequestStatus.underReview:
        return _StatusConfig(const Color(0xFFFFFDE7), const Color(0xFFF9A825));
      case RequestStatus.documentsMissing:
        return _StatusConfig(const Color(0xFFFFEBEE), Colors.red);
      case RequestStatus.inProgress:
        return _StatusConfig(const Color(0xFFE8EAF6), const Color(0xFF3949AB));
      case RequestStatus.approved:
        return _StatusConfig(const Color(0xFFE8F5E9), Colors.green);
      case RequestStatus.rejected:
        return _StatusConfig(const Color(0xFFFFEBEE), const Color(0xFFC62828));
      case RequestStatus.completed:
        return _StatusConfig(const Color(0xFFE0F7FA), const Color(0xFF00838F));
      case RequestStatus.cancelled:
        return _StatusConfig(const Color(0xFFF5F5F5), Colors.grey);
      case RequestStatus.taxPaid:
        return _StatusConfig(const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
      case RequestStatus.taxRejected:
        return _StatusConfig(const Color(0xFFFFEBEE), const Color(0xFFC62828));
    }
  }
}

class _StatusConfig {
  final Color bg;
  final Color text;
  const _StatusConfig(this.bg, this.text);
}