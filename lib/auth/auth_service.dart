/// Помилка автентифікації з повідомленням для користувача.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

/// Залежність AuthCubit: вхід і реєстрація.
/// Реалізації: FirebaseAuthService (реальна) і FakeAuthService (для e2e).
abstract class AuthService {
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password);
}
