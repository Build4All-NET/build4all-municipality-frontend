import 'package:baladiyati/features/citizen/requests/domain/entities/request_entity.dart';

class RequestsState {
  final bool isLoading;
  final List<RequestEntity> requests;
  final String? errorMessage;

  const RequestsState({
    this.isLoading = false,
    this.requests = const [],
    this.errorMessage,
  });

  RequestsState copyWith({
    bool? isLoading,
    List<RequestEntity>? requests,
    String? errorMessage,
  }) {
    return RequestsState(
      isLoading: isLoading ?? this.isLoading,
      requests: requests ?? this.requests,
      errorMessage: errorMessage,
    );
  }
}
