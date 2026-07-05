import 'dart:typed_data';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../services/payment_api_service.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentApiService _api;

  PaymentRepositoryImpl(this._api);

  @override
  Future<List<PaymentEntity>> getMyPayments() => _api.getMyPayments();

  @override
  Future<Uint8List> downloadReceipt(String requestId) =>
      _api.downloadReceipt(requestId);
}
