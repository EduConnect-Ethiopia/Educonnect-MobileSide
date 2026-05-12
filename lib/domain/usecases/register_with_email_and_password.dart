import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class RegisterWithEmailAndPassword {
  const RegisterWithEmailAndPassword(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _repository.register(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
