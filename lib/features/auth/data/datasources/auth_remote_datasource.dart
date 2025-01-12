import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> signInWithApple(String idToken, String accessToken,
      {String? givenName, String? familyName});
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSourceImpl(this._supabase);

  Future<void> _updateUserMetadata(
      {String? givenName, String? familyName}) async {
    if (givenName == null && familyName == null) return;

    final fullName = [givenName, familyName].where((e) => e != null).join(' ');
    if (fullName.isEmpty) return;

    try {
      await _supabase.auth.updateUser(
        UserAttributes(data: {'full_name': fullName}),
      );
    } catch (error) {
      print('Error updating user metadata: $error');
    }
  }

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
  Future<AuthResponse> signInWithApple(String idToken, String accessToken,
      {String? givenName, String? familyName}) async {
    try {
      print('Attempting to sign in with Apple...');
      print('ID Token: ${idToken.substring(0, 50)}...');
      print('Access Token: ${accessToken.substring(0, 20)}...');
      print('Given Name: $givenName');
      print('Family Name: $familyName');

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Update user metadata if name is provided
      await _updateUserMetadata(givenName: givenName, familyName: familyName);

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
