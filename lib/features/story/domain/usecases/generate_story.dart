import '../entities/story.dart';
import '../repositories/story_repository.dart';

class GenerateStoryUseCase {
  final StoryRepository repository;

  GenerateStoryUseCase(this.repository);

  Future<Story> execute({
    required String memory,
    required String genre,
    required String userId,
  }) {
    return repository.generateStory(
      memory: memory,
      genre: genre,
      userId: userId,
    );
  }
}
