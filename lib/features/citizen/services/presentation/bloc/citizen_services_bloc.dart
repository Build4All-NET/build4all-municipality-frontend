import 'package:baladiyati/core/utils/error_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/citizen_service_repository_impl.dart';
import '../../domain/usecases/get_citizen_services_usecase.dart';
import 'citizen_services_event.dart';
import 'citizen_services_state.dart';

class CitizenServicesBloc
    extends Bloc<CitizenServicesEvent, CitizenServicesState> {
  final GetCitizenServicesUseCase _getCitizenServicesUseCase;

  CitizenServicesBloc({
    GetCitizenServicesUseCase? getCitizenServicesUseCase,
  })  : _getCitizenServicesUseCase = getCitizenServicesUseCase ??
            GetCitizenServicesUseCase(
              CitizenServiceRepositoryImpl(),
            ),
        super(CitizenServicesState.initial()) {
    on<LoadCitizenServicesEvent>(_onLoadCitizenServices);
    on<RefreshCitizenServicesEvent>(_onRefreshCitizenServices);
  }

  Future<void> _onLoadCitizenServices(
    LoadCitizenServicesEvent event,
    Emitter<CitizenServicesState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onRefreshCitizenServices(
    RefreshCitizenServicesEvent event,
    Emitter<CitizenServicesState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(
    Emitter<CitizenServicesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CitizenServicesStatus.loading,
        clearError: true,
      ),
    );

    try {
      final services = await _getCitizenServicesUseCase();

      emit(
        state.copyWith(
          status: CitizenServicesStatus.success,
          services: services,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CitizenServicesStatus.failure,
          errorMessage: errorMessage(error),
        ),
      );
    }
  }
}