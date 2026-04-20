class AuthToken {
  final String value;
  const AuthToken(this.value);
  bool get isNotEmpty => value.isNotEmpty;
}
