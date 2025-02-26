import '../repositories/story_repository.dart';

class IncrementContinuationCountUseCase {
  final StoryRepository repository;

  IncrementContinuationCountUseCase(this.repository);

  Future<void> execute(int storyId) async {
    return await repository.incrementContinuationCount(storyId);
  }
}
