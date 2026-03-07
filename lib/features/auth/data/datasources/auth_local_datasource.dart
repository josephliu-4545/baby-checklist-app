import '../../domain/entities/user.dart';

class AuthLocalDataSource {
  User? _currentUser;

  User? getCurrentUser() {
    return _currentUser;
  }

  void setCurrentUser(User user) {
    _currentUser = user;
  }

  void clear() {
    _currentUser = null;
  }
}
