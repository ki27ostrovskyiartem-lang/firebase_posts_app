import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth/auth_cubit.dart';
import 'auth/auth_state.dart';
import 'auth/fake_auth_service.dart';
import 'screens/auth_screen.dart';

/// Точка входу для e2e-тестів (Maestro): без Firebase, з FakeAuthService.
/// Збірка: flutter build web -t lib/main_e2e.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Maestro шукає елементи через дерево Semantics, на web його треба увімкнути.
  SemanticsBinding.instance.ensureSemantics();
  runApp(const E2eApp());
}

class E2eApp extends StatelessWidget {
  const E2eApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Posts (e2e)',
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      home: BlocProvider(
        create: (_) => AuthCubit(FakeAuthService()),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) => state is AuthSuccess
              ? Scaffold(
                  appBar: AppBar(title: const Text('Головна')),
                  body: Center(child: Text('Вітаємо, ${state.email}')),
                )
              : const AuthScreen(),
        ),
      ),
    );
  }
}
