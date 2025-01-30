import 'package:dartz/dartz.dart';
import 'package:storysparks/core/error/failures.dart';
import '../entities/story.dart';
import '../repositories/story_repository.dart';

class GetUserStoriesUseCase {
  final StoryRepository repository;

  GetUserStoriesUseCase(this.repository);

  Future<Either<Failure, List<Story>>> execute(String userId) async {
    try {
      final stories = await repository.getSavedStories(userId);
      return Right(stories);
    } catch (e) {
      return Left(ServerFailure('Failed to get user stories'));
    }
  }
}
