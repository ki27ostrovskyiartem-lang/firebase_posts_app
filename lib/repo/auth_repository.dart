import 'package:firebase_auth/firebase_auth.dart';

/// Помилка автентифікації з повідомленням для користувача.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

/// Обгортка над FirebaseAuth.
class AuthRepository {
  AuthRepository([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;

  /// Потік стану автентифікації (null, якщо користувач не увійшов).
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signUp(String email, String password) =>
      _run(() => _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password));

  Future<void> signIn(String email, String password) =>
      _run(() => _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password));

  Future<void> signOut() => _auth.signOut();

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    }
  }

  String _message(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Некоректна адреса пошти.';
      case 'email-already-in-use':
        return 'Така пошта вже зареєстрована.';
      case 'weak-password':
        return 'Занадто простий пароль (мінімум 6 символів).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неправильна пошта або пароль.';
      case 'network-request-failed':
        return 'Немає з’єднання з інтернетом.';
      case 'too-many-requests':
        return 'Забагато спроб. Спробуйте пізніше.';
      default:
        return 'Помилка автентифікації ($code).';
    }
  }
}
