import '../repositories/story_repository.dart';

class ContinueStoryUseCase {
  final StoryRepository _repository;

  ContinueStoryUseCase(this._repository);

  Future<String> call({
    required int storyId,
    required String continuationPrompt,
  }) async {
    return await _repository.continueStory(
      storyId: storyId,
      continuationPrompt: continuationPrompt,
    );
  }
}
