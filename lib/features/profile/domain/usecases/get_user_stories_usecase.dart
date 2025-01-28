import 'package:storysparks/features/story/domain/entities/story.dart';
import 'package:storysparks/features/story/domain/repositories/story_repository.dart';

class GetUserStoriesUseCase {
  final StoryRepository _storyRepository;

  GetUserStoriesUseCase(this._storyRepository);

  Future<List<Story>> call(String userId) {
    return _storyRepository.getSavedStories(userId);
  }
}
