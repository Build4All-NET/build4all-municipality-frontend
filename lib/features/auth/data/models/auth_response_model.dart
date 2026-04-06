// lib/features/auth/data/models/auth_response_model.dart
// What the server returns after login/register
// { "token": "eyJ...", "message": "Login successful" }

class AuthResponseModel {
  final String token;
  final String message;

  const AuthResponseModel({
    required this.token,
    required this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
