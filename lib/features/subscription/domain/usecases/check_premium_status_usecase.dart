import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/subscription/domain/repositories/subscription_repository.dart';

class CheckPremiumStatusUseCase implements UseCase<bool, NoParams> {
  final SubscriptionRepository repository;

  CheckPremiumStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isUserPremium();
  }
}
