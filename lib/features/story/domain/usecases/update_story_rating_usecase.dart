import '../repositories/story_repository.dart';

class UpdateStoryRatingUseCase {
  final StoryRepository _repository;

  UpdateStoryRatingUseCase(this._repository);

  Future<void> call(int storyId, double rating) async {
    await _repository.updateRating(storyId, rating);
  }
}
