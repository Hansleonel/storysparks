import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Caso de uso para marcar el onboarding como completado.
class MarkOnboardingCompleteUseCase implements UseCase<void, NoParams> {
  final OnboardingRepository repository;

  MarkOnboardingCompleteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.markOnboardingComplete();
  }
}
