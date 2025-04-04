import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/auth/domain/entities/profile.dart';
import 'package:memorysparks/features/auth/domain/repositories/auth_repository.dart';

class GetProfileUseCase implements UseCase<Profile?, NoParams> {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Profile?>> call(NoParams params) async {
    try {
      debugPrint('🔄 GetProfileUseCase: Getting current user...');
      final user = await repository.getCurrentUser();

      if (user == null) {
        debugPrint('⚠️ GetProfileUseCase: No current user found');
        return const Right(null);
      }

      debugPrint('✅ GetProfileUseCase: Current user found - ID: ${user.id}');
      debugPrint('🔄 GetProfileUseCase: Fetching profile details...');

      final result = await repository.getProfile(user.id);

      result.fold(
        (failure) => debugPrint(
            '❌ GetProfileUseCase: Failed to get profile - ${failure.message}'),
        (profile) => debugPrint(
            '✅ GetProfileUseCase: Profile fetched successfully - Username: ${profile?.username}'),
      );

      return result;
    } catch (e) {
      debugPrint('❌ GetProfileUseCase: Unexpected error - $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
