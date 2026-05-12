import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailAndPassword {
  const SignInWithEmailAndPassword(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
