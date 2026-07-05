import 'dart:typed_data';
import '../repositories/payment_repository.dart';

class DownloadReceipt {
  final PaymentRepository repository;
  const DownloadReceipt(this.repository);

  Future<Uint8List> call(String requestId) =>
      repository.downloadReceipt(requestId);
}
