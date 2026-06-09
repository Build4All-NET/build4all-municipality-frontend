import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladiyati/features/citizen/services/domain/usecases/get_citizen_services.dart';
import 'package:baladiyati/features/citizen/services/data/repositories/citizen_service_repository_impl.dart';
import 'package:baladiyati/features/citizen/services/data/services/citizen_service_api.dart';
import 'services_event.dart';
import 'services_state.dart';

class CitizenServicesBloc
    extends Bloc<CitizenServicesEvent, CitizenServicesState> {
  final GetCitizenServices _getServices;

  CitizenServicesBloc({GetCitizenServices? getServices})
      : _getServices = getServices ??
            GetCitizenServices(
                CitizenServiceRepositoryImpl(CitizenServiceApi())),
        super(const CitizenServicesState()) {
    on<CitizenServicesLoadRequested>(_onLoad);
    on<CitizenServicesRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(
      CitizenServicesEvent event, Emitter<CitizenServicesState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final services = await _getServices();
      emit(state.copyWith(isLoading: false, services: services));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}
