import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _auth;

  const AuthRepositoryImpl(this._auth);

  @override
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final current = result.user;
      if (current == null) {
        return null;
      }

      return User(
        id: current.uid,
        name: current.displayName ?? current.email ?? email,
        email: current.email ?? email,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final current = result.user;
      if (current == null) {
        throw Exception('Registration failed.');
      }

      await current.updateDisplayName(name);

      return User(
        id: current.uid,
        name: name,
        email: current.email ?? email,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  @override
  Future<void> logout() {
    return _auth.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final current = _auth.currentUser;
    if (current == null) {
      return null;
    }

    return User(
      id: current.uid,
      name: current.displayName ?? current.email ?? '',
      email: current.email ?? '',
    );
  }

  String _mapAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'That email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled for this project.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }
}
