import '../entities/story.dart';
import '../repositories/story_repository.dart';

class GetStoryByIdUseCase {
  final StoryRepository repository;

  GetStoryByIdUseCase(this.repository);

  Future<Story?> execute(int storyId) async {
    return await repository.getStoryById(storyId);
  }
}
