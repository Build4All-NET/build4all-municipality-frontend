import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/auth_api_service.dart';
import 'complete_profile_event.dart';
import 'complete_profile_state.dart';

class CompleteProfileBloc
    extends Bloc<CompleteProfileEvent, CompleteProfileState> {
  final AuthApiService authApi;

  CompleteProfileBloc({required this.authApi})
      : super(const CompleteProfileState()) {
    on<CompleteProfileSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    CompleteProfileSubmitted event,
    Emitter<CompleteProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await authApi.completeProfile(
        address: event.address,
        username: event.username,
        municipalityId: 1
      );

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
