import 'package:dartz/dartz.dart';
import 'package:storysparks/core/error/failures.dart';
import 'package:storysparks/features/profile/domain/entities/story.dart';

abstract class StoryRepository {
  Future<Either<Failure, List<Story>>> getUserStories();
}
