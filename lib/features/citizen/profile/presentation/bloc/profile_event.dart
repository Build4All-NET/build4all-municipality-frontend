abstract class ProfileEvent {}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileUpdateSubmitted extends ProfileEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String address;
  final String? profileImagePath;
  final bool imageRemoved;

  ProfileUpdateSubmitted({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    this.profileImagePath,
    this.imageRemoved = false,
  });
}