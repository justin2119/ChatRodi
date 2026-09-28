import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication operations backed by the configured Supabase project.
class AuthRepository {
  AuthRepository({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<AuthResponse> signUp(String email, String password) {
    return _client.auth.signUp(email: email.trim(), password: password);
  }

  Future<AuthResponse> signIn(String email, String password) {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  User? getCurrentUser() => _client.auth.currentUser;
}
