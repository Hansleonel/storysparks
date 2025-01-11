import 'package:dartz/dartz.dart';
import 'package:storysparks/core/error/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(String email, String password);
  Future<Either<Failure, AuthResponse>> signInWithApple(
      String idToken, String accessToken);
  Future<Either<Failure, void>> signOut();
}
