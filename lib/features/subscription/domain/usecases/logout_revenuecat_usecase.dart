import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/subscription/domain/repositories/subscription_repository.dart';

class LogoutRevenueCatUseCase implements UseCase<void, NoParams> {
  final SubscriptionRepository repository;

  LogoutRevenueCatUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logoutUser();
  }
}
