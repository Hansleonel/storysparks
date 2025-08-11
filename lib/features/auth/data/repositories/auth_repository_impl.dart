import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:memorysparks/features/auth/domain/entities/profile.dart';
import 'package:memorysparks/features/auth/domain/repositories/auth_repository.dart';
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
  Future<Either<Failure, AuthResponse>> signInWithGoogle(
      String idToken, String accessToken) async {
    try {
      final response =
          await _remoteDataSource.signInWithGoogle(idToken, accessToken);
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

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      print('🏛️ AuthRepositoryImpl: Iniciando eliminación de cuenta');
      print('📤 AuthRepositoryImpl: Llamando al datasource remoto');
      await _remoteDataSource.deleteAccount();
      print('✅ AuthRepositoryImpl: Cuenta eliminada con éxito');
      return const Right(null);
    } catch (e) {
      print('❌ AuthRepositoryImpl: Error en eliminación de cuenta: $e');
      // Analizar el error para dar un mensaje más específico
      String errorMessage = e.toString();
      if (errorMessage.contains('foreign key constraint')) {
        print(
            '🔑 AuthRepositoryImpl: Error de restricción de clave foránea detectado');
        return Left(ServerFailure(
            'No se pudo eliminar la cuenta debido a datos relacionados. Por favor, contacta a soporte.'));
      } else if (errorMessage.contains('permission denied')) {
        print('🔒 AuthRepositoryImpl: Error de permisos detectado');
        return Left(
            ServerFailure('No tienes permisos para realizar esta acción.'));
      } else {
        return Left(ServerFailure(errorMessage));
      }
    }
  }

  @override
  Future<Either<Failure, Profile>> updatePremiumStatus(
      {required bool isPremium}) async {
    try {
      final updatedProfile =
          await _remoteDataSource.updatePremiumStatus(isPremium: isPremium);
      return Right(updatedProfile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
