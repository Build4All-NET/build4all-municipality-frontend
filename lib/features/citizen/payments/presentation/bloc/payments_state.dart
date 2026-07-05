import 'package:baladiyati/features/citizen/payments/domain/entities/payment_entity.dart';

class PaymentsState {
  final bool isLoading;
  final List<PaymentEntity> payments;
  final String? errorMessage;
  final Set<String> downloadingIds;

  const PaymentsState({
    this.isLoading = false,
    this.payments = const [],
    this.errorMessage,
    this.downloadingIds = const {},
  });

  List<PaymentEntity> get pendingPayments =>
      payments.where((p) => p.isPending).toList();

  List<PaymentEntity> get paidPayments =>
      payments.where((p) => p.isPaid).toList();

  bool isDownloading(String requestId) => downloadingIds.contains(requestId);

  PaymentsState copyWith({
    bool? isLoading,
    List<PaymentEntity>? payments,
    String? errorMessage,
    Set<String>? downloadingIds,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      payments: payments ?? this.payments,
      errorMessage: errorMessage,
      downloadingIds: downloadingIds ?? this.downloadingIds,
    );
  }
}
