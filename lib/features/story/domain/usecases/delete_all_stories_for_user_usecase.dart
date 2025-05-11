import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/story/domain/repositories/story_repository.dart';

class DeleteAllStoriesForUserUseCase
    implements UseCase<void, DeleteAllStoriesParams> {
  final StoryRepository repository;

  DeleteAllStoriesForUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAllStoriesParams params) async {
    try {
      await repository.deleteAllStoriesForUser(params.userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class DeleteAllStoriesParams extends Equatable {
  final String userId;

  const DeleteAllStoriesParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
