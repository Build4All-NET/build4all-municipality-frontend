// lib/app/app_router.dart

import 'package:baladiyati/core/network/dio_client.dart';
import 'package:baladiyati/features/admin/Departement/data/Repository/Departement_Repo_Impl.dart';
import 'package:baladiyati/features/admin/Departement/data/Service/Departement_Api_Service.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Add_departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Delete_departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Get_Departement.dart';
import 'package:baladiyati/features/admin/Departement/domain/Usecases/Update_Departement.dart';
import 'package:baladiyati/features/admin/Departement/presentation/bloc/Departement_Event.dart';
import 'package:baladiyati/features/admin/Departement/presentation/cubit/Departement_cubit.dart';
import 'package:baladiyati/features/admin/Departement/presentation/screens/Add_Depart_screen.dart';
import 'package:baladiyati/features/admin/Departement/presentation/screens/Departement_Screen.dart';
import 'package:baladiyati/features/admin/Role/Presenatation/cubit/role_cubit.dart';
import 'package:baladiyati/features/admin/Role/data/service/Role_Api_Service.dart';
import 'package:baladiyati/features/admin/manage_service/presentation/screens/Service_screen.dart';
import 'package:baladiyati/features/admin/staff/Domain/Usecase/GetEmploye.dart';
import 'package:baladiyati/features/admin/staff/Domain/Usecase/GreateEmploye.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_bloc.dart';
import 'package:baladiyati/features/admin/staff/Presentation/bloc/Empl_event.dart';
import 'package:baladiyati/features/admin/staff/Presentation/screens/Employe_screen.dart';
import 'package:baladiyati/features/admin/staff/data/Repository/Empl_Repo.dart';
import 'package:baladiyati/features/admin/staff/data/Service/Employe_Api_Service.dart';
import 'package:baladiyati/features/admin/violations/data/Repository/violation_Repository_impl.dart';
import 'package:baladiyati/features/admin/violations/data/services/violation_api_services.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/AddViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/DeleteViolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/Getviolation.dart';
import 'package:baladiyati/features/admin/violations/domain/Usecase/UpdateViolation.dart';
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => ViolationRepositoryImpl(ViolationApiService()),
          child: BlocProvider(
            create: (context) {
              final repo = context.read<ViolationRepositoryImpl>();

              return ViolationBloc(
                addViolation: AddViolation(repo),
                getViolations: GetViolations(repo),
                updateViolation: UpdateViolation(repo),
                deleteViolation: DeleteViolation(repo)
              );
            },
            child: const ViolationsPage(),
          ),
        ),
      ),
    );
  }
static void goToDepartments(BuildContext context) {
  final repo = DepartmentRepositoryImpl(
    DepartmentApiService(DioClient.muni),
  );

  final getDepartments = GetDepartments(repo);
  final addDepartment = AddDepartment(repo);
  final deleteDepartment = DeleteDepartment(repo);
  final updateDepartment = UpdateDepartment(repo);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => DepartmentCubit(
          getDepartments,
          addDepartment,
          deleteDepartment,
          updateDepartment,
        )..fetchDepartments(), // ✔️ صح مش load
        child: const DepartmentsScreen(),
      ),
    ),
  );
}
 // ================= EMPLOYEES =================
 
static void goToEmployees(BuildContext context) {
  final employeeRepo = EmployeeRepositoryImpl(
    EmployeeApiService(DioClient.muni),
  );

  final roleApi = RoleApiService(DioClient.muni);
  final departmentApi = DepartmentApiService(DioClient.muni);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [

          BlocProvider(
            create: (_) => EmployeeBloc(
              GetEmployees(employeeRepo),
              CreateEmployee(employeeRepo),
            )..add(LoadEmployees()),
          ),

          BlocProvider(
            create: (_) => RoleCubit(roleApi)..load(),
          ),

          BlocProvider(
            create: (_) => DepartmentCubit(
  GetDepartments(
    DepartmentRepositoryImpl(
      DepartmentApiService(DioClient.muni),
    ),
  ),
  AddDepartment(
    DepartmentRepositoryImpl(
      DepartmentApiService(DioClient.muni),
    ),
  ),
  DeleteDepartment(
    DepartmentRepositoryImpl(
      DepartmentApiService(DioClient.muni),
    ),
  ),
  UpdateDepartment(
    DepartmentRepositoryImpl(
      DepartmentApiService(DioClient.muni),
    ),
  ),
)..fetchDepartments()
          ),
        ],
        child: const EmployeesScreen(),
      ),
    ),
  );
}
static void goToServices(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>  ServicesScreen(),
    ),
  );
}
}

