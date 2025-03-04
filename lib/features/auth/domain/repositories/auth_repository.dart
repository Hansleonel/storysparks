import 'package:dartz/dartz.dart';
import 'package:storysparks/core/error/failures.dart';
import 'package:storysparks/features/auth/domain/entities/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(String email, String password);
  Future<Either<Failure, AuthResponse>> signInWithApple(
      String idToken, String accessToken,
      {String? givenName, String? familyName});
  Future<Either<Failure, AuthResponse>> signInWithGoogle(
      String idToken, String accessToken);
  Future<Either<Failure, void>> signOut();
  Future<User?> getCurrentUser();
  Future<Either<Failure, Profile>> updateProfile(Profile profile);
  Future<Either<Failure, Profile?>> getProfile(String userId);
  Future<Either<Failure, Profile>> register({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? bio,
  });
  Future<void> logout();
}
