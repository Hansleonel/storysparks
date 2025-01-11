import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> signInWithApple(String idToken, String accessToken);
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSourceImpl(this._supabase);

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      throw Exception('Error signing in: $error');
    }
  }

  @override
  Future<AuthResponse> signInWithApple(
      String idToken, String accessToken) async {
    try {
      print('Attempting to sign in with Apple...');
      print('ID Token: ${idToken.substring(0, 50)}...');
      print('Access Token: ${accessToken.substring(0, 20)}...');

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        accessToken: accessToken,
      );

      print('Sign in successful: ${response.user?.email}');
      return response;
    } catch (error) {
      print('Error details: $error');
      if (error is AuthException) {
        print('Status Code: ${error.statusCode}');
        print('Message: ${error.message}');
      }
      throw Exception('Error signing in with Apple: $error');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      throw Exception('Error signing out: $error');
    }
  }
}
