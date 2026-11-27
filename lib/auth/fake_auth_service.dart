import 'auth_service.dart';

/// Проста реалізація в пам'яті для e2e-тестів (без Firebase).
/// Заздалегідь зареєстрований користувач: user@test.com / Test123!
class FakeAuthService implements AuthService {
  final Map<String, String> _users = {'user@test.com': 'Test123!'};

  @override
  Future<void> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_users[email] != password) {
      throw AuthException('Неправильна пошта або пароль.');
    }
  }

  @override
  Future<void> signUp(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_users.containsKey(email)) {
      throw AuthException('Така пошта вже зареєстрована.');
    }
    _users[email] = password;
  }
}
