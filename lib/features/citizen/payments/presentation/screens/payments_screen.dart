import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/l10n/app_localizations.dart';
import 'package:baladiyati/features/citizen/payments/domain/entities/payment_entity.dart';
import 'package:baladiyati/features/citizen/payments/presentation/bloc/payments_bloc.dart';
import 'package:baladiyati/features/citizen/payments/presentation/bloc/payments_event.dart';
import 'package:baladiyati/features/citizen/payments/presentation/bloc/payments_state.dart';
import 'package:baladiyati/features/citizen/payments/data/services/payment_api_service.dart';
import 'package:baladiyati/features/citizen/payments/data/repositories/payment_repository_impl.dart';
import 'package:baladiyati/features/citizen/payments/domain/usecases/get_my_payments.dart';
import 'package:baladiyati/features/citizen/payments/domain/usecases/download_receipt.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => PaymentsBloc(
        getMyPayments: GetMyPayments(
          PaymentRepositoryImpl(PaymentApiService()),
        ),
        downloadReceipt: DownloadReceipt(
          PaymentRepositoryImpl(PaymentApiService()),
        ),
      )..add(PaymentsLoadRequested()),
      child: BlocBuilder<PaymentsBloc, PaymentsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, l10n, state),
                  if (state.isLoading && state.payments.isEmpty)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.errorMessage != null &&
                      state.payments.isEmpty)
                    _buildError(context, l10n, state)
                  else
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPaidList(context, l10n, state),
                          _buildPendingList(context, l10n, state),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AppLocalizations l10n, PaymentsState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (state.errorMessage != null && state.payments.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF1E3A5F)),
                  onPressed: () => context
                      .read<PaymentsBloc>()
                      .add(PaymentsRefreshRequested()),
                )
              else
                const SizedBox.shrink(),
              Text(
                l10n.navPayments,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF1E3A5F),
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: '${l10n.paid} (${state.paidPayments.length})'),
                Tab(text: '${l10n.pending} (${state.pendingPayments.length})'),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildError(
      BuildContext context, AppLocalizations l10n, PaymentsState state) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? l10n.loadFailed,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context
                    .read<PaymentsBloc>()
                    .add(PaymentsRefreshRequested()),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingList(
      BuildContext context, AppLocalizations l10n, PaymentsState state) {
    final pending = state.pendingPayments;
    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Colors.green.shade300),
            const SizedBox(height: 16),
            Text(l10n.noPayments,
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context
          .read<PaymentsBloc>()
          .add(PaymentsRefreshRequested()),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pending.length,
        itemBuilder: (_, i) => _buildPendingCard(context, l10n, pending[i]),
      ),
    );
  }

  Widget _buildPaidList(
      BuildContext context, AppLocalizations l10n, PaymentsState state) {
    final paid = state.paidPayments;
    if (paid.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(l10n.noPayments,
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context
          .read<PaymentsBloc>()
          .add(PaymentsRefreshRequested()),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: paid.length,
        itemBuilder: (_, i) =>
            _buildPaidCard(context, l10n, paid[i], state),
      ),
    );
  }

  Widget _buildPendingCard(
      BuildContext context, AppLocalizations l10n, PaymentEntity p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.due,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p.title,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (p.trackingNumber.isNotEmpty)
              Text(
                '${l10n.tracking} ${p.trackingNumber}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            if (p.createdAt != null)
              Text(
                '${l10n.date} ${_formatDate(p.createdAt!)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            if (p.serviceName != null)
              Text(
                p.serviceName!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (p.amount != null)
                  Text(
                    '${_formatAmount(p.amount!.toInt())} ${l10n.lbp}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaidCard(
      BuildContext context, AppLocalizations l10n, PaymentEntity p,
      PaymentsState state) {
    final downloading = state.isDownloading(p.requestId);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          size: 14, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      Text(
                        l10n.paidLabel,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p.title,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (p.trackingNumber.isNotEmpty)
              Text(
                '${l10n.tracking} ${p.trackingNumber}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            if (p.paidAt != null)
              Text(
                '${l10n.paidDate} ${_formatDate(p.paidAt!)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            if (p.receiptNumber != null)
              Text(
                '${l10n.receiptNumber} ${p.receiptNumber}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            if (p.serviceName != null)
              Text(
                p.serviceName!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: downloading
                      ? null
                      : () => context
                          .read<PaymentsBloc>()
                          .add(PaymentsDownloadReceipt(p.requestId)),
                  icon: downloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download, size: 16),
                  label: Text(downloading ? l10n.loading : l10n.downloadReceipt),
                ),
                if (p.amount != null)
                  Text(
                    '${_formatAmount(p.amount!.toInt())} ${l10n.lbp}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}