abstract class AuthEvent {}

class AuthLoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  final String role;

  AuthLoginSubmitted({
    required this.email,
    required this.password,
    required this.role,
  });
}

class AuthLoggedOut extends AuthEvent {}

class AuthUserPatched extends AuthEvent {
  final String? fullName;
  final String? username;
  final String? avatarUrl;
  final String? address;
  final String? status;

  AuthUserPatched({
    this.fullName,
    this.username,
    this.avatarUrl,
    this.address,
    this.status,
  });
}