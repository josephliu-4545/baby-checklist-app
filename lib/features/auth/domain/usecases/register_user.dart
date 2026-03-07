import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository _authRepository;

  const RegisterUser(this._authRepository);

  Future<User> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _authRepository.register(
      name: name,
      email: email,
      password: password,
    );
  }
}

