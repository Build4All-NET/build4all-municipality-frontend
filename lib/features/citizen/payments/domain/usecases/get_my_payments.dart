import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class GetMyPayments {
  final PaymentRepository repository;
  const GetMyPayments(this.repository);

  Future<List<PaymentEntity>> call() => repository.getMyPayments();
}
