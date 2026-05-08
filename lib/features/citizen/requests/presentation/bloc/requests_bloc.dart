// lib/features/citizen/requests/presentation/bloc/requests_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/features/citizen/services/data/services/request_service.dart';
import 'requests_event.dart';
import 'requests_state.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final RequestService _requestService;

  RequestsBloc({RequestService? requestService})
      : _requestService = requestService ?? RequestService(),
        super(const RequestsState()) {
    on<RequestsLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    RequestsLoadRequested event,
    Emitter<RequestsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final requests = await _requestService.getMyRequests();
      emit(state.copyWith(isLoading: false, requests: requests));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}