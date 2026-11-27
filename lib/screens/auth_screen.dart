import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';

/// Екран входу і реєстрації. Логіка в AuthCubit (береться з контексту).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _register = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final busy = state is AuthLoading;
        return Scaffold(
          appBar: AppBar(title: Text(_register ? 'Реєстрація' : 'Вхід')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      key: const Key('email'),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Пошта'),
                    ),
                    TextField(
                      key: const Key('password'),
                      controller: _pass,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Пароль'),
                    ),
                    const SizedBox(height: 16),
                    busy
                        ? const CircularProgressIndicator()
                        : FilledButton(
                            onPressed: () => context.read<AuthCubit>().submit(
                                _email.text, _pass.text,
                                register: _register),
                            child:
                                Text(_register ? 'Зареєструватись' : 'Увійти'),
                          ),
                    TextButton(
                      onPressed: () => setState(() => _register = !_register),
                      child: Text(_register
                          ? 'Вже є акаунт? Увійти'
                          : 'Немає акаунта? Зареєструватись'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
