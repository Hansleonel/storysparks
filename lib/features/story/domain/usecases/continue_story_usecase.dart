import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:storysparks/core/error/failures.dart';
import '../entities/story.dart';
import '../repositories/story_repository.dart';

class ContinueStoryUseCase {
  final StoryRepository repository;

  ContinueStoryUseCase(this.repository);

  Future<Either<Failure, Story>> execute(Story story) async {
    debugPrint('📖 ContinueStoryUseCase: Iniciando continuación de historia');
    debugPrint('   ID: ${story.id}');
    debugPrint('   Género: ${story.genre}');
    debugPrint('   Longitud actual: ${story.content.length} caracteres');

    try {
      debugPrint('📖 ContinueStoryUseCase: Llamando al repositorio...');
      final continuedStory = await repository.continueStory(story);

      debugPrint('✅ ContinueStoryUseCase: Historia continuada exitosamente');
      debugPrint(
          '   Nueva longitud: ${continuedStory.content.length} caracteres');
      debugPrint(
          '   Incremento: ${continuedStory.content.length - story.content.length} caracteres');

      return Right(continuedStory);
    } catch (e) {
      debugPrint('❌ ContinueStoryUseCase: Error durante la continuación');
      debugPrint('   Error detallado: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
