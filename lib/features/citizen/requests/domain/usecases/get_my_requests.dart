import '../entities/request_entity.dart';
import '../repositories/request_repository.dart';

class GetMyRequests {
  final CitizenRequestRepository repository;
  const GetMyRequests(this.repository);

  Future<List<RequestEntity>> call() => repository.getMyRequests();
}
