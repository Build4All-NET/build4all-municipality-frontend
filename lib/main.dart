// lib/main.dart

import 'package:baladiyati/app/app.dart';
import 'package:baladiyati/common/registration_step_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/l10n/locale_cubit.dart';

Future<void> main() async {
  //  Pre-initialize SharedPreferences once before app starts
  // Prevents LocaleCubit and ThemeCubit from each calling getInstance()
  // separately on the main thread 
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

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
