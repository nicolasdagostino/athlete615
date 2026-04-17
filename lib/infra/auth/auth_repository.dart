import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client_provider.dart';

class AuthRepository {
  SupabaseClient get _client => SupabaseClientProvider.client;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
}
