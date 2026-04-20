abstract class AuthEvent {}

class AuthLoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  AuthLoginSubmitted({
    required this.email,
    required this.password,
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