// lib/features/auth/presentation/register/register_event.dart
import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

// حدث إرسال الكود للتسجيل بالإيميل فقط
class RegisterSendCodeSubmitted extends RegisterEvent {
  final String email;
  final String password;

  const RegisterSendCodeSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}