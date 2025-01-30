import '../entities/story.dart';
import '../repositories/story_repository.dart';

class SaveStoryUseCase {
  final StoryRepository repository;

  SaveStoryUseCase(this.repository);

  Future<int> execute(Story story) async {
    return await repository.saveStory(story);
  }
}
