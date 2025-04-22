import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/domain/repositories/locale_repository.dart';
import '../entities/story.dart';
import '../entities/story_params.dart';
import '../repositories/story_repository.dart';

class GenerateStoryUseCase {
  final StoryRepository repository;
  final LocaleRepository localeRepository;

  GenerateStoryUseCase({
    required this.repository,
    required this.localeRepository,
  });

  Future<Either<Failure, Story>> execute({
    required StoryParams params,
    required String userId,
  }) async {
    debugPrint('📖 GenerateStoryUseCase: Iniciando generación de historia');
    debugPrint('📖 GenerateStoryUseCase: Parámetros recibidos:');
    debugPrint(
        '   - Memoria (longitud): ${params.memoryText.length} caracteres');
    debugPrint('   - Género: ${params.genre}');
    debugPrint('   - ID de usuario: $userId');
    if (params.imageDescription != null) {
      debugPrint(
          '   - Descripción de imagen disponible: ${params.imageDescription}');
    }
    if (params.imagePath != null) {
      debugPrint('   - Ruta de la imagen: ${params.imagePath}');
    }

    try {
      // 1. Obtener el locale actual
      final locale = await localeRepository.getCurrentLocale();
      final languageCode = locale.languageCode;

      // 2. Crear nuevos parámetros con el idioma incluido
      final paramsWithLanguage = params.copyWith(targetLanguage: languageCode);

      debugPrint('📖 GenerateStoryUseCase: Llamando al repositorio...');
      final story = await repository.generateStory(
        params: paramsWithLanguage,
        userId: userId,
      );
      debugPrint('✅ GenerateStoryUseCase: Historia generada exitosamente');
      debugPrint('   - ID: ${story.id}');
      debugPrint('   - Título: ${story.title}');
      debugPrint('   - Género: ${story.genre}');
      debugPrint(
          '   - Longitud del contenido: ${story.content.length} caracteres');
      return Right(story);
    } catch (e) {
      debugPrint('❌ GenerateStoryUseCase: Error durante la generación');
      debugPrint('   Error detallado: $e');
      return Left(ServerFailure('Error al generar la historia: $e'));
    }
  }
}
