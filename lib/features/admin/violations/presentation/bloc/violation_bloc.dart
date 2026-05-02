import 'package:baladiyati/features/admin/violations/domain/Usecase/AddViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/Getviolation.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_event.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViolationBloc extends Bloc<ViolationEvent, ViolationState> {
  final AddViolation addViolation;
  final GetViolations getViolations;

  ViolationBloc(this.addViolation, this.getViolations)
      : super(ViolationInitial()) {

    on<LoadViolationsEvent>((event, emit) async {
      emit(ViolationLoading());
      try {
        final list = await getViolations();
        emit(ViolationLoaded(list));
      } catch (e) {
        emit(ViolationError("Failed to load violations"));
      }
    });

    on<CreateViolationEvent>((event, emit) async {
      emit(ViolationLoading());
      try {
        await addViolation(event.violation);
            emit(ViolationCreated()); // 🔥 نجاح إنشاء

        // 🔥 بعد الإضافة رجّع list
        final list = await getViolations();

        emit(ViolationLoaded(list)); // مهم
      } catch (e) {
        emit(ViolationError("Failed to create violation"));
      }
    });
  }
}