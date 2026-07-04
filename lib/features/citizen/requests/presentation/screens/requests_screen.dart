import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/common/widgets/app_search_field.dart';
import 'package:baladiyati/common/widgets/app_toast.dart';
import 'package:baladiyati/common/widgets/shimmer_loading.dart';
import 'package:baladiyati/features/citizen/requests/domain/entities/request_entity.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_bloc.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_event.dart';
import 'package:baladiyati/features/citizen/requests/presentation/bloc/requests_state.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'request_details_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _filterStatus;
  String? _lastShownError;

  static const List<String> _allStatuses = [
    'DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'DOCUMENTS_MISSING',
    'IN_PROGRESS', 'APPROVED', 'REJECTED', 'COMPLETED', 'CANCELLED',
    'TAX_PAID', 'TAX_REJECTED',
  ];

  @override
  void initState() {
    super.initState();
    final bloc = context.read<RequestsBloc>();
    if (!bloc.state.isLoading && bloc.state.requests.isEmpty) {
      bloc.add(RequestsLoadRequested());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<RequestEntity> _filtered(List<RequestEntity> all) => all.where((r) {
    final q = _query.trim().toLowerCase();
    final matchSearch = q.isEmpty ||
        r.title.toLowerCase().contains(q) ||
        r.trackingNumber.toLowerCase().contains(q) ||
        (r.serviceName?.toLowerCase().contains(q) ?? false);
    final matchStatus = _filterStatus == null || r.status == _filterStatus;
    return matchSearch && matchStatus;
  }).toList();

  String _statusLabel(AppLocalizations loc, String status) {
    switch (status) {
      case 'DRAFT': return loc.statusDraft;
      case 'SUBMITTED': return loc.statusSubmitted;
      case 'UNDER_REVIEW': return loc.statusUnderReview;
      case 'DOCUMENTS_MISSING': return loc.statusDocumentsMissing;
      case 'IN_PROGRESS': return loc.inProgress;
      case 'APPROVED': return loc.approved;
      case 'REJECTED': return loc.rejected;
      case 'COMPLETED': return loc.completed;
      case 'CANCELLED': return loc.statusCancelled;
      case 'TAX_PAID': return loc.statusTaxPaid;
      case 'TAX_REJECTED': return loc.statusTaxRejected;
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<RequestsBloc, RequestsState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage != _lastShownError) {
          _lastShownError = state.errorMessage;
          AppToast.show(context, message: state.errorMessage!, type: AppToastType.error);
        }
      },
      builder: (context, state) {
        final items = _filtered(state.requests);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: colors.surface,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.myRequests,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),
                      AppSearchField(
                        controller: _searchCtrl,
                        hint: loc.searchRequest,
                        onChanged: (v) => setState(() => _query = v),
                        onClear: _query.isEmpty
                            ? null
                            : () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                      ),
                      const SizedBox(height: 10),
                      // Status filter
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _filterStatus,
                            isExpanded: true,
                            hint: Text(loc.filterAll),
                            items: [
                              DropdownMenuItem<String?>(value: null, child: Text(loc.filterAll)),
                              ..._allStatuses.map((s) => DropdownMenuItem<String?>(
                                    value: s,
                                    child: Text(_statusLabel(loc, s)),
                                  )),
                            ],
                            onChanged: (v) => setState(() => _filterStatus = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: state.isLoading
                      ? const _RequestsSkeleton()
                      : items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.description_outlined, size: 64, color: colors.outline),
                                  const SizedBox(height: 12),
                                  Text(loc.noRequests,
                                      style: theme.textTheme.bodyLarge?.copyWith(color: colors.outline)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async =>
                                  context.read<RequestsBloc>().add(RequestsRefreshRequested()),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: items.length,
                                itemBuilder: (_, i) => _RequestCard(
                                  request: items[i],
                                  loc: loc,
                                  theme: theme,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RequestDetailsScreen(request: items[i]),
                                    ),
                                  ),
                                ),
                              ),
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

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _RequestsSkeleton extends StatelessWidget {
  const _RequestsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (_, __) => const _RequestCardSkeleton(),
    );
  }
}

class _RequestCardSkeleton extends StatelessWidget {
  const _RequestCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Expanded(flex: 6, child: ShimmerBox(height: 14)),
                      const Spacer(flex: 4),
                    ]),
                    const SizedBox(height: 5),
                    Row(children: [
                      const Expanded(flex: 4, child: ShimmerBox(height: 11)),
                      const Spacer(flex: 6),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const ShimmerBox(width: 72, height: 26, radius: 13),
            ],
          ),
          const SizedBox(height: 9),
          Row(children: [
            const ShimmerBox(width: 14, height: 14, radius: 4),
            const SizedBox(width: 4),
            const ShimmerBox(width: 110, height: 11),
          ]),
          const SizedBox(height: 7),
          Row(children: [
            const ShimmerBox(width: 14, height: 14, radius: 4),
            const SizedBox(width: 4),
            const ShimmerBox(width: 80, height: 11),
          ]),
        ],
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class StatusBadgeWidget extends StatelessWidget {
  final String status;
  const StatusBadgeWidget({super.key, required this.status});

  static String label(AppLocalizations loc, String status) {
    switch (status) {
      case 'DRAFT': return loc.statusDraft;
      case 'SUBMITTED': return loc.statusSubmitted;
      case 'UNDER_REVIEW': return loc.statusUnderReview;
      case 'DOCUMENTS_MISSING': return loc.statusDocumentsMissing;
      case 'IN_PROGRESS': return loc.inProgress;
      case 'APPROVED': return loc.approved;
      case 'REJECTED': return loc.rejected;
      case 'COMPLETED': return loc.completed;
      case 'CANCELLED': return loc.statusCancelled;
      case 'TAX_PAID': return loc.statusTaxPaid;
      case 'TAX_REJECTED': return loc.statusTaxRejected;
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final config = _config(colors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label(loc, status),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: config.text),
      ),
    );
  }

  _StatusColors _config(ColorScheme cs) {
    switch (status) {
      case 'DRAFT': return _StatusColors(cs.outline.withOpacity(0.12), cs.outline);
      case 'SUBMITTED': return _StatusColors(cs.primary.withOpacity(0.12), cs.primary);
      case 'UNDER_REVIEW': return _StatusColors(const Color(0xFFFFFDE7), const Color(0xFFF9A825));
      case 'DOCUMENTS_MISSING': return _StatusColors(cs.error.withOpacity(0.10), cs.error);
      case 'IN_PROGRESS': return _StatusColors(cs.secondary.withOpacity(0.12), cs.secondary);
      case 'APPROVED': return _StatusColors(const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
      case 'REJECTED': return _StatusColors(cs.error.withOpacity(0.12), cs.error);
      case 'COMPLETED': return _StatusColors(const Color(0xFFE0F7FA), const Color(0xFF00838F));
      case 'CANCELLED': return _StatusColors(cs.outline.withOpacity(0.12), cs.outline);
      case 'TAX_PAID': return _StatusColors(const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
      case 'TAX_REJECTED': return _StatusColors(cs.error.withOpacity(0.12), cs.error);
      default: return _StatusColors(cs.outline.withOpacity(0.12), cs.outline);
    }
  }
}

class _StatusColors {
  final Color bg;
  final Color text;
  const _StatusColors(this.bg, this.text);
}

// ── Request card ──────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final RequestEntity request;
  final AppLocalizations loc;
  final ThemeData theme;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.loc,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withOpacity(0.12)),
          boxShadow: [BoxShadow(color: colors.shadow.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.title.isNotEmpty ? request.title : (request.serviceName == null ? loc.requestDetails : switch (request.serviceName) {
                          'Building Permit' => loc.serviceBuildingPermit,
                          'Larger Building Permit' => loc.serviceLargerBuildingPermit,
                          'Housing Permit' => loc.serviceHousingPermit,
                          'External Works' => loc.serviceExternalWorks,
                          'Illegal Construction' => loc.serviceIllegalConstruction,
                          'Valuation Certificate' => loc.serviceValuationCertificate,
                          'Clearance Certificate' => loc.serviceClearanceCertificate,
                          'Tent Permit' => loc.serviceTentPermit,
                          'Property Access' => loc.servicePropertyAccess,
                          'Residence Certificate' => loc.serviceResidenceCertificate,
                          'Contents Certificate' => loc.serviceContentsCertificate,
                          'Work Certificate' => loc.serviceWorkCertificate,
                          'Lease Registration' => loc.serviceLeaseRegistration,
                          _ => request.serviceName!,
                        }),
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (request.trackingNumber.isNotEmpty)
                        Text(
                          '#${request.trackingNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.outline),
                        ),
                    ],
                  ),
                ),
                StatusBadgeWidget(status: request.status),
              ],
            ),
            if (request.serviceName != null && request.serviceName!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.description_outlined, size: 14, color: colors.outline),
                  const SizedBox(width: 4),
                  Text(
                    switch (request.serviceName!) {
                      'Building Permit' => loc.serviceBuildingPermit,
                      'Larger Building Permit' => loc.serviceLargerBuildingPermit,
                      'Housing Permit' => loc.serviceHousingPermit,
                      'External Works' => loc.serviceExternalWorks,
                      'Illegal Construction' => loc.serviceIllegalConstruction,
                      'Valuation Certificate' => loc.serviceValuationCertificate,
                      'Clearance Certificate' => loc.serviceClearanceCertificate,
                      'Tent Permit' => loc.serviceTentPermit,
                      'Property Access' => loc.servicePropertyAccess,
                      'Residence Certificate' => loc.serviceResidenceCertificate,
                      'Contents Certificate' => loc.serviceContentsCertificate,
                      'Work Certificate' => loc.serviceWorkCertificate,
                      'Lease Registration' => loc.serviceLeaseRegistration,
                      _ => request.serviceName!,
                    },
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.outline),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: colors.outline),
                const SizedBox(width: 4),
                Text(
                  _formatDate(request.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(color: colors.outline),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, size: 16, color: colors.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
