import 'dart:typed_data';
import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<List<PaymentEntity>> getMyPayments();
  Future<Uint8List> downloadReceipt(String requestId);
}
