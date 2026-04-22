import 'package:baladiyati/app/app.dart';
import 'package:baladiyati/common/registration_step_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/l10n/locale_cubit.dart';

// ✅ ADD THIS IMPORT
import 'package:baladiyati/core/network/dio_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferences.getInstance();

  // ✅ INIT DIO (Build4All + Municipality APIs)
  await DioClient.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit(),
        ),
        BlocProvider<RegistrationStepCubit>(
          create: (_) => RegistrationStepCubit(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}