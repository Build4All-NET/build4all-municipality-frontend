// lib/features/auth/domain/usecases/login_with_email.dart
// ─────────────────────────────────────────
// UseCase: Login with email and password
// Calls the repository
// ─────────────────────────────────────────
import 'package:baladiyati/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';

// Screens
//import 'package:baladiyati/features/auth/presentation/login/screens/reset_password_page.dart';
import '../repository/auth_repository.dart';

class LoginWithEmail {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String ownerProjectLinkId,
  }) {
    var ownerProjectLinkId = null;
    return repository.loginWithEmail(email: email, password: password, ownerProjectLinkId: ownerProjectLinkId, 
    
    );
}
}