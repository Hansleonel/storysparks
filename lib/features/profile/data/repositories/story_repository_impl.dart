import 'package:dartz/dartz.dart';
import 'package:storysparks/core/error/failures.dart';
import 'package:storysparks/features/profile/data/datasources/story_local_datasource.dart';
import 'package:storysparks/features/profile/domain/entities/story.dart';
import 'package:storysparks/features/profile/domain/repositories/story_repository.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryLocalDataSource localDataSource;

  StoryRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Story>>> getUserStories() async {
    try {
      final stories = await localDataSource.getUserStories();
      return Right(stories);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
