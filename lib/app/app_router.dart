// lib/app/app_router.dart

import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/Delete_service.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/update_service.dart';
import 'package:baladiyati/features/admin/profile/data/repositories/admin_profile_repository_impl.dart';
import 'package:baladiyati/features/admin/profile/data/services/admin_profile_api_service.dart';
import 'package:baladiyati/features/admin/profile/domain/usecases/get_admin_profile_usecase.dart';

import 'package:baladiyati/features/admin/profile/presentation/cubit/admin_profile_cubit.dart';
import 'package:baladiyati/features/admin/profile/presentation/screens/admin_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/data/services/auth_api_service.dart';
import '../features/auth/presentation/complete_profile/screens/complete_profile_screen.dart';
import '../features/auth/presentation/login/bloc/auth_bloc.dart';
import '../features/auth/presentation/login/screens/login_screen.dart';
import '../features/auth/presentation/register/screens/user_register_screen.dart';
import '../features/auth/presentation/register/screens/user_verify_code_screen.dart';
import '../features/citizen/home/presentation/screens/home_screen.dart';
import '../features/citizen/profile/presentation/bloc/profile_bloc.dart';
import '../features/citizen/profile/presentation/screens/profile_screen.dart';
import '../features/forgotpassword/presentation/screens/forgot_password_screen.dart';
import '../features/forgotpassword/presentation/screens/reset_password_page.dart';
import '../features/forgotpassword/presentation/screens/verify_reset_code_screen.dart';
import '../features/welcome/presentation/screens/welcome_screen.dart';

// Admin dashboard pages
import 'package:baladiyati/features/admin/announcements/presentation/screens/announcementscreen.dart';
import 'package:baladiyati/features/admin/violations/presentation/screens/violationpage.dart';

// Departments
import 'package:baladiyati/features/admin/Departement/data/Repository/Departement_Repo_Impl.dart';
import 'package:baladiyati/features/admin/Departement/data/Service/Departement_Api_Service.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Add_departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Delete_departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Get_Departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Update_Departement.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/features/admin/Departement/presentation/screens/Departement_Screen.dart';

// Services
import 'package:baladiyati/features/admin/manage_service/Data/Repository/Service_Repository_impl.dart';
import 'package:baladiyati/features/admin/manage_service/Data/service/Service_Api_service.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/Create_service.dart';
import 'package:baladiyati/features/admin/manage_service/Domain/usecases/Get_service.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_bloc.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/bloc/Service_event.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/screens/Service_screen.dart';

// Employees
import 'package:baladiyati/features/admin/staff/Domain/Usecase/GetEmploye.dart';
import 'package:baladiyati/features/admin/staff/Domain/Usecase/GreateEmploye.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_bloc.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_event.dart';
import 'package:baladiyati/features/admin/staff/Presentation/screens/Employe_screen.dart';
import 'package:baladiyati/features/admin/staff/data/Repository/Empl_Repo.dart';
import 'package:baladiyati/features/admin/staff/data/Service/Employe_Api_Service.dart';

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
        builder: (_) => ForgotPasswordScreen(
          email: email,
          code: code,
        ),
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
      ),
    );
  }

  // ================= ADMIN: ANNOUNCEMENTS =================

  static void goToAnnouncements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AnnouncementsPage(),
      ),
    );
  }

  // ================= ADMIN: VIOLATIONS =================

  static void goToViolations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ViolationsPage(),
      ),
    );
  }

  // ================= ADMIN: DEPARTMENTS =================

  static void goToDepartments(BuildContext context) {
  final repository = DepartmentRepositoryImpl(
    DepartmentApiService(DioClient.muni),
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => DepartmentCubit(
          GetDepartments(repository),
          AddDepartment(repository),
          DeleteDepartment(repository),
          UpdateDepartment(repository),
        )..fetchDepartments(),
        child: const DepartmentsScreen(),
      ),
    ),
  );
}

  // ================= ADMIN: SERVICES =================

static void goToServices(BuildContext context) {
  final repository = ServiceRepositoryImpl(
    ServiceApiService(DioClient.muni),
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => ServiceBloc(
          getServices: GetServices(repository),
          createService: CreateService(repository),
          updateService: UpdateService(repository),
          deleteService: DeleteService(repository),
        )..add(LoadServices()),
        child: const ServicesScreen(),
      ),
    ),
  );
}
  static void goToManageServices(BuildContext context) {
    goToServices(context);
  }

 static void goToAdminProfile(BuildContext context) {
  final repository = AdminProfileRepositoryImpl(
    api: AdminProfileApiService(
      dio: DioClient.build,
    ),
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => AdminProfileCubit(
          getAdminProfile: GetAdminProfileUseCase(repository),
       
        )..loadProfile(),
        child: const AdminProfileScreen(),
      ),
    ),
  );
}

  // ================= ADMIN: EMPLOYEES =================

 static void goToEmployees(BuildContext context) {
  final employeeRepository = EmployeeRepositoryImpl(
    EmployeeApiService(DioClient.muni),
  );

  final departmentRepository = DepartmentRepositoryImpl(
    DepartmentApiService(DioClient.muni),
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => EmployeeBloc(
              GetEmployees(employeeRepository),
              CreateEmployee(employeeRepository),
            )..add(LoadEmployees()),
          ),
          BlocProvider(
            create: (_) => DepartmentCubit(
              GetDepartments(departmentRepository),
              AddDepartment(departmentRepository),
              DeleteDepartment(departmentRepository),
              UpdateDepartment(departmentRepository),
            )..fetchDepartments(),
          ),
        ],
        child: const EmployeesScreen(),
      ),
    ),
  );
}

  
}