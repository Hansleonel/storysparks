import 'package:dartz/dartz.dart';
import 'package:storysparks/core/error/failures.dart';
import 'package:storysparks/core/usecases/usecase.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';

class GetUserNameUseCase implements UseCase<String?, NoParams> {
  final AuthRepository repository;

  GetUserNameUseCase(this.repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    try {
      final user = await repository.getCurrentUser();
      final fullName = user?.userMetadata?['full_name'] as String?;

      if (fullName == null || fullName.isEmpty) {
        return const Right(null);
      }

      // Obtener solo el primer nombre
      final firstName = fullName.split(' ').first;

      // Capitalizar la primera letra si es necesario
      final capitalizedName = firstName.isNotEmpty
          ? firstName[0].toUpperCase() + firstName.substring(1).toLowerCase()
          : firstName;

      return Right(capitalizedName);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
