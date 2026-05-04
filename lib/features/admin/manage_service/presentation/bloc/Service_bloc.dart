import 'package:baladiyati/features/admin/manage_service/Domain/usecases/Create_service.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/Get_service.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/delete_service.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/update_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Service_event.dart';
import 'Service_State.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final GetServices getServices;
  final AddService addService;
  final DeleteService deleteService;
  final UpdateService updateService;

  ServiceBloc(
    this.getServices,
    this.addService,
    this.deleteService,
    this.updateService,
  ) : super(ServiceInitial()) {

    // ✅ LOAD
    on<LoadServices>((event, emit) async {
      emit(ServiceLoading());
      try {
        final data = await getServices();
        emit(ServiceLoaded(data));
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });

    // ✅ CREATE
    on<AddServiceEvent>((event, emit) async {
      try {
        await addService(event.service);
        add(LoadServices());
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });

    // ✅ UPDATE
   on<UpdateServiceEvent>((event, emit) async {
  emit(ServiceLoading());
  try {
    await updateService(event.id, event.service);
    add(LoadServices());
  } catch (e) {
    emit(ServiceError(e.toString()));
  }
});

    // ✅ DELETE (optimized local update)
    on<DeleteServiceEvent>((event, emit) async {
      try {
        await deleteService(event.id);

        final currentState = state;
        if (currentState is ServiceLoaded) {
          final updatedList = currentState.services
              .where((s) => s.id != event.id)
              .toList();

          emit(ServiceLoaded(updatedList));
        }
      } catch (e) {
        emit(ServiceError(e.toString()));
      }
    });
  }
}