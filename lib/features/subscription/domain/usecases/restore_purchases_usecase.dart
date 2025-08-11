import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/subscription/domain/entities/customer_info_entity.dart';
import 'package:memorysparks/features/subscription/domain/repositories/subscription_repository.dart';

class RestorePurchasesUseCase implements UseCase<CustomerInfoEntity, NoParams> {
  final SubscriptionRepository repository;

  RestorePurchasesUseCase(this.repository);

  @override
  Future<Either<Failure, CustomerInfoEntity>> call(NoParams params) async {
    return await repository.restorePurchases();
  }
}
