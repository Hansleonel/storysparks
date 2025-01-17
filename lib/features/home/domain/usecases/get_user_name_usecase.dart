import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:storysparks/core/error/failures.dart';
import 'package:storysparks/core/usecases/usecase.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';

class GetUserNameUseCase implements UseCase<String?, NoParams> {
  final AuthRepository repository;

  GetUserNameUseCase(this.repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    try {
      debugPrint('🔍 GetUserNameUseCase: Starting to fetch user name...');

      final user = await repository.getCurrentUser();
      debugPrint('👤 Current user: ${user?.id ?? 'No user found'}');

      if (user == null) {
        debugPrint('⚠️ No authenticated user found');
        return const Right(null);
      }

      debugPrint('📊 Fetching profile for user ID: ${user.id}');
      final profileResult = await repository.getProfile(user.id);

      return profileResult.fold(
        (failure) {
          debugPrint('❌ Error fetching profile: ${failure.message}');
          return Left(failure);
        },
        (profile) {
          if (profile == null) {
            debugPrint('⚠️ No profile found for user');
            return const Right(null);
          }

          debugPrint(
              '✅ Profile found: username=${profile.username}, fullName=${profile.fullName}');

          final fullName = profile.fullName;
          if (fullName == null || fullName.isEmpty) {
            debugPrint(
                'ℹ️ Using username as display name: ${profile.username}');
            return Right(profile.username);
          }

          final firstName = fullName.split(' ').first;
          final capitalizedName = firstName.isNotEmpty
              ? firstName[0].toUpperCase() +
                  firstName.substring(1).toLowerCase()
              : firstName;

          debugPrint('✨ Final display name: $capitalizedName');
          return Right(capitalizedName);
        },
      );
    } catch (e) {
      debugPrint('❌ Unexpected error in GetUserNameUseCase: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
