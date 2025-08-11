import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:memorysparks/features/subscription/data/datasources/revenuecat_datasource.dart';
import 'package:memorysparks/features/subscription/data/models/package_model.dart';
import 'package:memorysparks/features/subscription/domain/entities/customer_info_entity.dart';
import 'package:memorysparks/features/subscription/domain/entities/offering_entity.dart';
import 'package:memorysparks/features/subscription/domain/entities/package_entity.dart';
import 'package:memorysparks/features/subscription/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final RevenueCatDataSource revenueCatDataSource;
  final AuthRepository authRepository;

  SubscriptionRepositoryImpl({
    required this.revenueCatDataSource,
    required this.authRepository,
  });

  @override
  Future<Either<Failure, void>> initializeWithUser(String userId) async {
    try {
      await revenueCatDataSource.initializeWithUser(userId);

      // Sync premium status after initialization
      await syncPremiumStatusWithBackend();

      return const Right(null);
    } catch (e) {
      log('❌ Failed to initialize RevenueCat: $e');
      return Left(
          ServerFailure('Failed to initialize RevenueCat: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logoutUser() async {
    try {
      await revenueCatDataSource.logoutUser();
      return const Right(null);
    } catch (e) {
      log('❌ Failed to logout from RevenueCat: $e');
      return Left(
          ServerFailure('Failed to logout from RevenueCat: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserPremium() async {
    try {
      final isPremium = await revenueCatDataSource.isUserPremium();
      return Right(isPremium);
    } catch (e) {
      log('❌ Failed to check premium status: $e');
      return Left(
          ServerFailure('Failed to check premium status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CustomerInfoEntity>> getCustomerInfo() async {
    try {
      final customerInfo = await revenueCatDataSource.getCustomerInfo();
      return Right(customerInfo);
    } catch (e) {
      log('❌ Failed to get customer info: $e');
      return Left(
          ServerFailure('Failed to get customer info: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<OfferingEntity>>> getOfferings() async {
    try {
      final offerings = await revenueCatDataSource.getOfferings();
      return Right(offerings);
    } catch (e) {
      log('❌ Failed to get offerings: $e');
      return Left(ServerFailure('Failed to get offerings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CustomerInfoEntity>> purchasePackage(
    PackageEntity package,
  ) async {
    try {
      if (package is! PackageModel) {
        throw Exception('Package must be a PackageModel');
      }

      final customerInfo = await revenueCatDataSource.purchasePackage(package);

      // Sync with backend after successful purchase
      await syncPremiumStatusWithBackend();

      return Right(customerInfo);
    } catch (e) {
      log('❌ Failed to purchase package: $e');
      return Left(ServerFailure('Failed to purchase package: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CustomerInfoEntity>> restorePurchases() async {
    try {
      final customerInfo = await revenueCatDataSource.restorePurchases();

      // Sync with backend after restore
      await syncPremiumStatusWithBackend();

      return Right(customerInfo);
    } catch (e) {
      log('❌ Failed to restore purchases: $e');
      return Left(
          ServerFailure('Failed to restore purchases: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> syncPremiumStatusWithBackend() async {
    try {
      log('🔄 Syncing premium status with backend...');

      // Get current premium status from RevenueCat
      final isPremiumResult = await isUserPremium();

      return isPremiumResult.fold(
        (failure) => Left(failure),
        (isPremium) async {
          log('📊 RevenueCat premium status: $isPremium');

          // Update premium status in Supabase
          final updateResult = await authRepository.updatePremiumStatus(
            isPremium: isPremium,
          );

          return updateResult.fold(
            (failure) {
              log('❌ Failed to sync with backend: $failure');
              return Left(failure);
            },
            (profile) {
              log('✅ Backend updated successfully: ${profile.isPremium}');
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      log('❌ Error syncing premium status: $e');
      return Left(
          ServerFailure('Failed to sync premium status: ${e.toString()}'));
    }
  }
}
