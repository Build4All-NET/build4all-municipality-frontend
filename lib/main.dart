import 'package:baladiyati/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/l10n/locale_cubit.dart';
import 'features/auth/presentation/login/screens/login_screen.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
