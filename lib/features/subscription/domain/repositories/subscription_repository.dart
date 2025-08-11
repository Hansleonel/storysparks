import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/features/subscription/domain/entities/customer_info_entity.dart';
import 'package:memorysparks/features/subscription/domain/entities/offering_entity.dart';
import 'package:memorysparks/features/subscription/domain/entities/package_entity.dart';

abstract class SubscriptionRepository {
  /// Initialize RevenueCat with user ID
  Future<Either<Failure, void>> initializeWithUser(String userId);

  /// Logout from RevenueCat
  Future<Either<Failure, void>> logoutUser();

  /// Check if user is premium
  Future<Either<Failure, bool>> isUserPremium();

  /// Get customer information
  Future<Either<Failure, CustomerInfoEntity>> getCustomerInfo();

  /// Get available offerings
  Future<Either<Failure, List<OfferingEntity>>> getOfferings();

  /// Purchase a package
  Future<Either<Failure, CustomerInfoEntity>> purchasePackage(
    PackageEntity package,
  );

  /// Restore purchases
  Future<Either<Failure, CustomerInfoEntity>> restorePurchases();

  /// Sync premium status with backend
  Future<Either<Failure, void>> syncPremiumStatusWithBackend();
}
