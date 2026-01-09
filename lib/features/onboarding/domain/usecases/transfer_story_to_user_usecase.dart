import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';

/// Parámetros para transferir la historia al usuario.
class TransferStoryParams {
  final Story story;
  final String userId;

  TransferStoryParams({
    required this.story,
    required this.userId,
  });
}

/// Caso de uso para transferir la historia generada al usuario después del registro.
class TransferStoryToUserUseCase {
  final OnboardingRepository repository;

  TransferStoryToUserUseCase(this.repository);

  Future<Either<Failure, Story>> call(TransferStoryParams params) async {
    return await repository.transferStoryToUser(params.story, params.userId);
  }
}
