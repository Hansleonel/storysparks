import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:storysparks/core/error/failures.dart';
import '../entities/story.dart';
import '../repositories/story_repository.dart';

class ContinueStoryUseCase {
  final StoryRepository _repository;

  ContinueStoryUseCase(this._repository);

  Future<Either<Failure, Story>> execute(Story story) async {
    debugPrint('📖 ContinueStoryUseCase: Iniciando continuación de historia');
    debugPrint('   ID: ${story.id}');
    debugPrint('   Género: ${story.genre}');
    debugPrint('   Longitud actual: ${story.content.length} caracteres');

    try {
      debugPrint('📖 ContinueStoryUseCase: Llamando al repositorio...');
      final updatedStory = await _repository.continueStory(story);

      debugPrint('✅ ContinueStoryUseCase: Historia continuada exitosamente');
      debugPrint(
          '   Nueva longitud: ${updatedStory.content.length} caracteres');
      debugPrint(
          '   Incremento: ${updatedStory.content.length - story.content.length} caracteres');

      return Right(updatedStory);
    } catch (e) {
      debugPrint('❌ ContinueStoryUseCase: Error durante la continuación');
      debugPrint('   Error detallado: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
