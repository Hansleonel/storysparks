import '../repositories/story_repository.dart';

class UpdateStoryStatusUseCase {
  final StoryRepository _repository;

  UpdateStoryStatusUseCase(this._repository);

  Future<void> call(int storyId, String status) async {
    await _repository.updateStoryStatus(storyId, status);
  }
}
