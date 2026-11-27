import '../repo/auth_repository.dart';
import 'auth_service.dart';

/// Адаптер: AuthRepository (Firebase) як AuthService.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._repo);
  final AuthRepository _repo;

  @override
  Future<void> signIn(String email, String password) =>
      _repo.signIn(email, password);

  @override
  Future<void> signUp(String email, String password) =>
      _repo.signUp(email, password);
}
