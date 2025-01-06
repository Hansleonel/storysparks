import '../repositories/story_repository.dart';

class DeleteStoryUseCase {
  final StoryRepository _repository;

  DeleteStoryUseCase(this._repository);

  Future<void> call(int storyId) async {
    await _repository.deleteStory(storyId);
  }
}
