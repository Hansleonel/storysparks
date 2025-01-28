import 'package:storysparks/features/story/domain/entities/story.dart';
import 'package:storysparks/features/story/domain/repositories/story_repository.dart';
import 'package:flutter/foundation.dart';

class ContinueStoryUseCase {
  final StoryRepository repository;

  ContinueStoryUseCase(this.repository);

  Future<Story> call(ContinueStoryParams params) {
    debugPrint('🎯 Ejecutando ContinueStoryUseCase');
    debugPrint('📖 Historia anterior ID: ${params.previousStory.id}');
    debugPrint('👤 Usuario ID: ${params.userId}');

    return repository.continueStory(
      previousStory: params.previousStory,
      userId: params.userId,
    );
  }
}

class ContinueStoryParams {
  final Story previousStory;
  final String userId;

  ContinueStoryParams({
    required this.previousStory,
    required this.userId,
  });
}
