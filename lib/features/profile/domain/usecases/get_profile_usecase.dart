import 'package:dartz/dartz.dart';
import 'package:storysparks/core/error/failures.dart';
import 'package:storysparks/core/usecases/usecase.dart';
import 'package:storysparks/features/auth/domain/entities/profile.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';

class GetProfileUseCase implements UseCase<Profile?, NoParams> {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Profile?>> call(NoParams params) async {
    try {
      final user = await repository.getCurrentUser();
      if (user == null) {
        return const Right(null);
      }

      return await repository.getProfile(user.id);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
