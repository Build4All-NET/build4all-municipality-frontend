import 'package:baladiyati/features/admin/manage_service/Data/model/service_Model.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/Create_service.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/Get_service.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_State.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final GetServices getServices;
  final CreateService createService;

  List<ServiceModel> allServices = [];

  ServiceBloc(this.getServices, this.createService)
      : super(ServiceLoading()) {

    on<LoadServices>((event, emit) async {
      emit(ServiceLoading());
      try {
        allServices = await getServices();
        emit(ServiceLoaded(allServices));
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });

    on<FilterServices>((event, emit) {
      if (event.departmentId == null) {
        emit(ServiceLoaded(allServices));
      } else {
        final filtered = allServices
            .where((s) => s.departmentId == event.departmentId)
            .toList();

        emit(ServiceLoaded(filtered));
      }
    });

    on<AddService>((event, emit) async {
      await createService(event.service);
      add(LoadServices());
    });
  }
}