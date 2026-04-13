import 'package:baladiyati/app/app.dart';
import 'package:baladiyati/common/registration_step_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/l10n/locale_cubit.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit(),
        ),

        // ✅ ADD THIS
        BlocProvider<RegistrationStepCubit>(
          create: (_) => RegistrationStepCubit(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}