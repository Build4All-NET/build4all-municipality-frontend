// lib/app/app_router.dart

import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/Departement/data/Repository/Departement_Repo_Impl.dart';
import 'package:baladiyati/features/admin/Departement/data/Service/Departement_Api_Service.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Get_Departement.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_Event.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_bloc.dart';
import 'package:baladiyati/features/admin/Departement/presentation/screens/Departement_Screen.dart';
import 'package:baladiyati/features/admin/violations/data/Repository/violation_Repository_impl.dart';
import 'package:baladiyati/features/admin/violations/data/services/violation_api_services.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/AddViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/Getviolation.dart';
import 'package:baladiyati/features/admin/violations/presentation/bloc/violation_bloc.dart';
import 'package:baladiyati/features/admin/violations/presentation/screens/violationpage.dart';
import 'package:baladiyati/features/citizen/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/data/services/auth_api_service.dart';
import '../features/auth/presentation/complete_profile/screens/complete_profile_screen.dart';
import '../features/auth/presentation/login/bloc/auth_bloc.dart';
import '../features/auth/presentation/login/screens/login_screen.dart';
import '../features/auth/presentation/register/screens/user_register_screen.dart';
import '../features/auth/presentation/register/screens/user_verify_code_screen.dart';
import '../features/citizen/home/presentation/screens/home_screen.dart';
import '../features/citizen/profile/presentation/screens/profile_screen.dart';
import '../features/forgotpassword/presentation/screens/forgot_password_screen.dart';
import '../features/forgotpassword/presentation/screens/reset_password_page.dart';
import '../features/forgotpassword/presentation/screens/verify_reset_code_screen.dart';
import '../features/welcome/presentation/screens/welcome_screen.dart';

class AppRouter {
  static void goToWelcome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  static void goToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => AuthBloc(authApi: AuthApiService()),
          child: const LoginScreen(),
        ),
      ),
      (_) => false,
    );
  }

  static void gotoRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserRegisterScreen()),
    );
  }

  static void gotoUserVerifyCodeScreen(
    BuildContext context, {
    required String email,
    required String sharedReference,
    required String password,
    required int ownerProjectLinkId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserVerifyCodeScreen(
          email: email,
          sharedReference: sharedReference,
          password: password,
          ownerProjectLinkId: ownerProjectLinkId,
        ),
      ),
    );
  }

  static void gotoCompleteProfile(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
      (_) => false,
    );
  }

  static void gotoResetPasswordPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
    );
  }

  static void gotoVerifyResetCodeScreen(BuildContext context, String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyResetCodeScreen(email: email),
      ),
    );
  }

  static void gotoForgotPasswordScreen(
    BuildContext context,
    String email, {
    String code = '',
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(email: email , code: code),
      ),
    );
  }

  static void gotoHomePage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  static void goToProfile(BuildContext context) {
    Navigator.push(
      context,
    MaterialPageRoute(
  builder: (_) => BlocProvider(
    create: (_) => ProfileBloc(),
    child: const ProfileScreen(),
  ),
)
    );
  }
  static void goToViolations(BuildContext context) {
  final repo = ViolationRepositoryImpl(ViolationApiService());

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => ViolationBloc(
          AddViolation(repo),
          GetViolations(repo),
        ),
        child: const ViolationsPage(),
      ),
    ),
  );
}
static void goToDepartments(BuildContext context) {
  final repo = DepartmentRepositoryImpl(
    DepartmentApiService(DioClient.muni),
  );

  final getDepartments = GetDepartments(repo);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) =>
            DepartmentBloc(getDepartments)..add(LoadDepartments()),
        child: const DepartmentsPage(),
      ),
    ),
  );
}
}