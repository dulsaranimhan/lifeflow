import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Auth used by the rest of the app.
class AuthRepository {
  AuthRepository(this._auth);

  final GoTrueClient _auth;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> authStateChanges() => _auth.onAuthStateChange;

  /// Creates an account. [name] is stored in user metadata and copied
  /// into `profiles.name` by the `handle_new_user` database trigger.
  Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name.trim()},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email.trim(), password: password);
  }

  Future<void> signOut() => _auth.signOut();
}
