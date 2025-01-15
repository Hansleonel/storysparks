import 'package:dartz/dartz.dart';
import 'package:storysparks/core/error/failures.dart';
import 'package:storysparks/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:storysparks/features/auth/domain/entities/profile.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, AuthResponse>> login(
      String email, String password) async {
    try {
      final response = await _remoteDataSource.login(email, password);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> signInWithApple(
      String idToken, String accessToken,
      {String? givenName, String? familyName}) async {
    try {
      final response = await _remoteDataSource.signInWithApple(
          idToken, accessToken,
          givenName: givenName, familyName: familyName);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(Profile profile) async {
    try {
      final updatedProfile = await _remoteDataSource.updateProfile(profile);
      return Right(updatedProfile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Profile?>> getProfile(String userId) async {
    try {
      final profile = await _remoteDataSource.getProfile(userId);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Profile>> register({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? bio,
  }) async {
    try {
      final profile = await _remoteDataSource.register(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
        bio: bio,
      );
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
