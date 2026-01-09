import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Caso de uso para verificar si es la primera vez que el usuario abre la app.
class CheckFirstTimeUserUseCase implements UseCase<bool, NoParams> {
  final OnboardingRepository repository;

  CheckFirstTimeUserUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isFirstTimeUser();
  }
}
