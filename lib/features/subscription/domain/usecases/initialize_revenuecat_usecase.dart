import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/subscription/domain/repositories/subscription_repository.dart';

class InitializeRevenueCatUseCase implements UseCase<void, String> {
  final SubscriptionRepository repository;

  InitializeRevenueCatUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    return await repository.initializeWithUser(userId);
  }
}
