import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/subscription/domain/entities/customer_info_entity.dart';
import 'package:memorysparks/features/subscription/domain/entities/package_entity.dart';
import 'package:memorysparks/features/subscription/domain/repositories/subscription_repository.dart';

class PurchasePackageUseCase
    implements UseCase<CustomerInfoEntity, PackageEntity> {
  final SubscriptionRepository repository;

  PurchasePackageUseCase(this.repository);

  @override
  Future<Either<Failure, CustomerInfoEntity>> call(
      PackageEntity package) async {
    return await repository.purchasePackage(package);
  }
}
