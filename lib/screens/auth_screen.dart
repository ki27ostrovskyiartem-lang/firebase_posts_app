import 'package:flutter/material.dart';
import '../repo/auth_repository.dart';

/// Екран входу і реєстрації (перемикач режиму).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.auth});
  final AuthRepository auth;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _register = false;
  bool _busy = false;

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      if (_register) {
        await widget.auth.signUp(_email.text, _pass.text);
      } else {
        await widget.auth.signIn(_email.text, _pass.text);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _busy
                    ? const CircularProgressIndicator()
                    : FilledButton(
                        onPressed: _submit,
                        child: Text(_register ? 'Зареєструватись' : 'Увійти'),
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
  }
}
