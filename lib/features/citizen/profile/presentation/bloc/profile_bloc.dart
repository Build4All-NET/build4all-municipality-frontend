// lib/features/profile/presentation/bloc/profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/profile_api_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileApiService _api;

  ProfileBloc({ProfileApiService? api})
      : _api = api ?? ProfileApiService(),
        super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateSubmitted>(_onUpdateSubmitted);
  }

  // ─────────────────────────────────────────────────
  // Load profile
  // ─────────────────────────────────────────────────
  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final profile = await _api.getProfile(ownerProjectLinkId: 12);
      emit(state.copyWith(isLoading: false, profile: profile));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }

  // ─────────────────────────────────────────────────
  // Update profile
  // ─────────────────────────────────────────────────
  Future<void> _onUpdateSubmitted(
    ProfileUpdateSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, errorMessage: null, isUpdateSuccess: false));

    try {
      final updated = await _api.updateProfile(
        ownerProjectLinkId: 12,
        fullName: event.fullName,
        phone: event.phone,
        address: event.address,
        username: event.username,
      );
      emit(state.copyWith(
        isUpdating: false,
        isUpdateSuccess: true,
        profile: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        isUpdateSuccess: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}
