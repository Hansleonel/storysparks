import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/subscription/data/datasources/freemium_local_datasource.dart';

/// Entity to hold quota information
class StoryQuotaInfo extends Equatable {
  final int savedCount;
  final int maxFree;
  final int remaining;
  final bool canSaveMore;

  const StoryQuotaInfo({
    required this.savedCount,
    required this.maxFree,
    required this.remaining,
    required this.canSaveMore,
  });

  @override
  List<Object?> get props => [savedCount, maxFree, remaining, canSaveMore];
}

/// Parameters for checking story quota
class CheckStoryQuotaParams extends Equatable {
  final String userId;

  const CheckStoryQuotaParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Use case to check the story quota for a user
class CheckStoryQuotaUseCase implements UseCase<StoryQuotaInfo, CheckStoryQuotaParams> {
  final FreemiumLocalDatasource datasource;

  CheckStoryQuotaUseCase(this.datasource);

  @override
  Future<Either<Failure, StoryQuotaInfo>> call(CheckStoryQuotaParams params) async {
    try {
      final savedCount = await datasource.getSavedStoryCount(params.userId);
      final remaining = await datasource.getRemainingStorySlots(params.userId);
      final canSaveMore = await datasource.canSaveMoreStories(params.userId);

      return Right(StoryQuotaInfo(
        savedCount: savedCount,
        maxFree: FreemiumLocalDatasource.maxFreeStories,
        remaining: remaining,
        canSaveMore: canSaveMore,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

