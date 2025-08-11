import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/subscription/domain/entities/offering_entity.dart';
import 'package:memorysparks/features/subscription/domain/repositories/subscription_repository.dart';

class GetOfferingsUseCase implements UseCase<List<OfferingEntity>, NoParams> {
  final SubscriptionRepository repository;

  GetOfferingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<OfferingEntity>>> call(NoParams params) async {
    return await repository.getOfferings();
  }
}
