import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_service.dart';
import 'auth_state.dart';

/// Логіка входу й реєстрації: перевірка полів, виклик сервісу, стани.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._service) : super(const AuthInitial());
  final AuthService _service;

  /// Мінімальна довжина пароля (граничне значення для тестів).
  static const minPasswordLength = 6;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Future<void> submit(String email, String password,
      {required bool register}) async {
    final e = email.trim();
    if (e.isEmpty) {
      emit(const AuthFailure('Введіть пошту.'));
      return;
    }
    if (!_emailRe.hasMatch(e)) {
      emit(const AuthFailure('Некоректна адреса пошти.'));
      return;
    }
    if (password.length < minPasswordLength) {
      emit(const AuthFailure('Пароль має містити щонайменше 6 символів.'));
      return;
    }
    emit(const AuthLoading());
    try {
      if (register) {
        await _service.signUp(e, password);
      } else {
        await _service.signIn(e, password);
      }
      emit(AuthSuccess(e));
    } on AuthException catch (ex) {
      emit(AuthFailure(ex.message));
    } catch (_) {
      emit(const AuthFailure('Невідома помилка. Спробуйте ще раз.'));
    }
  }
}
