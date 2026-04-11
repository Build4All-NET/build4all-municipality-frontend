import 'package:flutter_bloc/flutter_bloc.dart';

class RegistrationStepCubit extends Cubit<int> {
  RegistrationStepCubit() : super(0); // 0 = Register

  void nextStep() => emit(state + 1);

  void goToStep(int step) => emit(step);

  void reset() => emit(0);
}