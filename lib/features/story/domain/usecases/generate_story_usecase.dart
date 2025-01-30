import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:storysparks/core/error/failures.dart';
import '../entities/story.dart';
import '../repositories/story_repository.dart';

class GenerateStoryUseCase {
  final StoryRepository repository;

  GenerateStoryUseCase(this.repository);

  Future<Either<Failure, Story>> execute({
    required String memory,
    required String genre,
    required String userId,
  }) async {
    debugPrint('📖 GenerateStoryUseCase: Iniciando generación de historia');
    debugPrint('📖 GenerateStoryUseCase: Parámetros recibidos:');
    debugPrint('   - Memoria (longitud): ${memory.length} caracteres');
    debugPrint('   - Género: $genre');
    debugPrint('   - ID de usuario: $userId');

    try {
      debugPrint('📖 GenerateStoryUseCase: Llamando al repositorio...');
      final story = await repository.generateStory(
        memory: memory,
        genre: genre,
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
