import '../repositories/auth_repository.dart';

class RequestPasswordReset {
  const RequestPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) {
    return _repository.requestPasswordReset(email);
  }
}
