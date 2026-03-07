import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

class AuthController extends ChangeNotifier {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final Future<User?> Function() _getCurrentUser;
  final Future<void> Function() _logout;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthController(
    this._loginUser,
    this._registerUser,
    this._getCurrentUser,
    this._logout,
  );

  User? get currentUser => _currentUser;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _setError(null);
    _setLoading(true);

    try {
      final user = await _loginUser(
        email: email,
        password: password,
      );

      if (user == null) {
        _setLoading(false);
        _setError('Login failed');
        notifyListeners();
        return false;
      }

      _currentUser = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceFirst('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setError(null);
    _setLoading(true);

    try {
      final user = await _registerUser(
        name: name,
        email: email,
        password: password,
      );

      _currentUser = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceFirst('Exception: ', ''));
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      _currentUser = await _getCurrentUser();
      notifyListeners();
    } catch (_) {
      // Ignore.
    }
  }

  Future<void> logout() async {
    await _logout();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String? message) {
    _errorMessage = message;
  }
}
