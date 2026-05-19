import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/features/citizen/requests/domain/usecases/get_my_requests.dart';
import 'package:baladiyati/features/citizen/requests/data/repositories/request_repository_impl.dart';
import 'package:baladiyati/features/citizen/requests/data/services/request_api_service.dart';
import 'requests_event.dart';
import 'requests_state.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final GetMyRequests _getMyRequests;

  RequestsBloc({GetMyRequests? getMyRequests})
      : _getMyRequests = getMyRequests ??
            GetMyRequests(CitizenRequestRepositoryImpl(RequestApiService())),
        super(const RequestsState()) {
    on<RequestsLoadRequested>(_onLoad);
    on<RequestsRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(RequestsEvent event, Emitter<RequestsState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final requests = await _getMyRequests();
      emit(state.copyWith(isLoading: false, requests: requests));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}
