class PaymentEntity {
  final String requestId;
  final String trackingNumber;
  final String title;
  final String? serviceName;
  final String status;
  final double? amount;
  final DateTime? paidAt;
  final String? receiptNumber;
  final DateTime? createdAt;

  const PaymentEntity({
    required this.requestId,
    required this.trackingNumber,
    required this.title,
    required this.status,
    this.serviceName,
    this.amount,
    this.paidAt,
    this.receiptNumber,
    this.createdAt,
  });

  bool get isPaid => status == 'TAX_PAID';
  bool get isPending => status == 'APPROVED';
}
