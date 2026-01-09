import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';

/// Repositorio abstracto para el onboarding.
abstract class OnboardingRepository {
  /// Verifica si es la primera vez que el usuario abre la app.
  Future<Either<Failure, bool>> isFirstTimeUser();

  /// Marca el onboarding como completado.
  Future<Either<Failure, void>> markOnboardingComplete();

  /// Guarda los datos del onboarding temporalmente.
  Future<Either<Failure, void>> saveOnboardingData(OnboardingData data);

  /// Obtiene los datos del onboarding guardados temporalmente.
  Future<Either<Failure, OnboardingData?>> getOnboardingData();

  /// Limpia los datos temporales del onboarding.
  Future<Either<Failure, void>> clearOnboardingData();

  /// Transfiere la historia generada al usuario después del registro.
  Future<Either<Failure, Story>> transferStoryToUser(
    Story story,
    String userId,
  );
}
