import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.requestId,
    required super.trackingNumber,
    required super.title,
    required super.status,
    super.serviceName,
    super.amount,
    super.paidAt,
    super.receiptNumber,
    super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      requestId: (json['requestId'] ?? '').toString(),
      trackingNumber: (json['trackingNumber'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? '').toString().toUpperCase(),
      serviceName: json['serviceName']?.toString(),
      amount: _toDouble(json['amount']),
      paidAt: _parseDate(json['paidAt']),
      receiptNumber: json['receiptNumber']?.toString(),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    return double.tryParse(v.toString());
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}
