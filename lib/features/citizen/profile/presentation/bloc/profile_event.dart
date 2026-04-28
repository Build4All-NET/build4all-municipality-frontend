// lib/features/profile/presentation/bloc/profile_event.dart

abstract class ProfileEvent {}

// Load profile
class ProfileLoadRequested extends ProfileEvent {}

// Update profile
class ProfileUpdateSubmitted extends ProfileEvent {
  final String? fullName;
  final String? phone;
  final String? address;
  final String? username;

  ProfileUpdateSubmitted({
    this.fullName,
    this.phone,
    this.address,
    this.username,
  });
}
