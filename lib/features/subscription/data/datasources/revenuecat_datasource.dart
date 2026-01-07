import 'dart:developer';

import 'package:memorysparks/core/constants/revenuecat_constants.dart';
import 'package:memorysparks/features/subscription/data/models/customer_info_model.dart';
import 'package:memorysparks/features/subscription/data/models/offering_model.dart';
import 'package:memorysparks/features/subscription/data/models/package_model.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class RevenueCatDataSource {
  Future<void> initializeWithUser(String userId);
  Future<void> logoutUser();
  Future<bool> isUserPremium();
  Future<CustomerInfoModel> getCustomerInfo();
  Future<List<OfferingModel>> getOfferings();
  Future<CustomerInfoModel> purchasePackage(PackageModel package);
  Future<CustomerInfoModel> restorePurchases();
  void setCustomerInfoUpdateListener(Function(CustomerInfoModel) onUpdate);
  void removeCustomerInfoUpdateListener();
}

class RevenueCatDataSourceImpl implements RevenueCatDataSource {
  bool _isInitialized = false;
  Function(CustomerInfo)? _currentListener;

  @override
  Future<void> initializeWithUser(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      log('🔧 Initializing RevenueCat with user ID: $userId');

      // Configure RevenueCat with debug logging
      await Purchases.setLogLevel(LogLevel.debug);

      // Configure RevenueCat with user ID
      final configuration = PurchasesConfiguration(RevenueCatConstants.apiKey)
        ..appUserID = userId;

      await Purchases.configure(configuration);
      _isInitialized = true;

      // Verify configuration
      final customerInfo = await Purchases.getCustomerInfo();
      log('✅ RevenueCat configured successfully. UserID: ${customerInfo.originalAppUserId}');
      log('💎 Initial premium status: ${customerInfo.entitlements.active.containsKey(RevenueCatConstants.entitlementId)}');
    } catch (e) {
      log('❌ Error initializing RevenueCat: $e');
      rethrow;
    }
  }

  @override
  void setCustomerInfoUpdateListener(Function(CustomerInfoModel) onUpdate) {
    if (!_isInitialized) {
      log('⚠️ Cannot set listener: RevenueCat not initialized');
      return;
    }

    log('👂 Setting up CustomerInfo update listener');

    // Create the listener function
    _currentListener = (customerInfo) {
      log('🔔 CustomerInfo updated automatically');
      log('💎 New premium status: ${customerInfo.entitlements.active.containsKey(RevenueCatConstants.entitlementId)}');

      final model = CustomerInfoModel.fromRevenueCat(
        customerInfo,
        RevenueCatConstants.entitlementId,
      );
      onUpdate(model);
    };

    // RevenueCat automatically calls this listener when:
    // - App comes to foreground (every 5 minutes if in foreground)
    // - After a purchase
    // - After restore
    // - When subscription status changes
    Purchases.addCustomerInfoUpdateListener(_currentListener!);
  }

  @override
  void removeCustomerInfoUpdateListener() {
    if (!_isInitialized || _currentListener == null) {
      return;
    }

    log('👋 Removing CustomerInfo update listener');
    Purchases.removeCustomerInfoUpdateListener(_currentListener!);
    _currentListener = null;
  }

  @override
  Future<void> logoutUser() async {
    try {
      if (!_isInitialized) {
        log('ℹ️ RevenueCat not initialized, nothing to logout');
        return;
      }

      final originalInfo = await Purchases.getCustomerInfo();
      final originalId = originalInfo.originalAppUserId;
      log('🔐 Logging out user: $originalId');

      await Purchases.logOut();
      _isInitialized = false;

      // Verify logout
      final newInfo = await Purchases.getCustomerInfo();
      final newId = newInfo.originalAppUserId;
      log('🆔 New anonymous ID: $newId');

      if (newId.contains('RCAnonymousID')) {
        log('✅ Logout successful, anonymous ID generated');
      } else {
        log('⚠️ Possible issue with logout');
      }
    } catch (e) {
      log('❌ Error logging out from RevenueCat: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isUserPremium() async {
    try {
      if (!_isInitialized) {
        log('⚠️ RevenueCat not initialized');
        return false;
      }

      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements.active
          .containsKey(RevenueCatConstants.entitlementId);

      log('💎 Premium status for ${customerInfo.originalAppUserId}: $isPremium');
      return isPremium;
    } catch (e) {
      log('❌ Error checking premium status: $e');
      return false;
    }
  }

  @override
  Future<CustomerInfoModel> getCustomerInfo() async {
    try {
      if (!_isInitialized) {
        throw Exception('RevenueCat not initialized');
      }

      final customerInfo = await Purchases.getCustomerInfo();
      return CustomerInfoModel.fromRevenueCat(
        customerInfo,
        RevenueCatConstants.entitlementId,
      );
    } catch (e) {
      log('❌ Error getting customer info: $e');
      rethrow;
    }
  }

  @override
  Future<List<OfferingModel>> getOfferings() async {
    try {
      if (!_isInitialized) {
        throw Exception('RevenueCat not initialized');
      }

      final offerings = await Purchases.getOfferings();
      final offeringsList = <OfferingModel>[];

      // Add current offering first if available
      if (offerings.current != null) {
        offeringsList.add(OfferingModel.fromRevenueCat(offerings.current!));
      }

      // Add other offerings
      for (final offering in offerings.all.values) {
        if (offering.identifier != offerings.current?.identifier) {
          offeringsList.add(OfferingModel.fromRevenueCat(offering));
        }
      }

      log('📦 Retrieved ${offeringsList.length} offerings');
      return offeringsList;
    } catch (e) {
      log('❌ Error getting offerings: $e');
      rethrow;
    }
  }

  @override
  Future<CustomerInfoModel> purchasePackage(PackageModel package) async {
    try {
      if (!_isInitialized) {
        throw Exception('RevenueCat not initialized');
      }

      log('💳 Starting purchase: ${package.identifier}');
      final result = await Purchases.purchasePackage(package.originalPackage);

      // Check if entitlement is active
      final hasEntitlement = result.entitlements.active
          .containsKey(RevenueCatConstants.entitlementId);

      if (hasEntitlement) {
        log('🎉 Purchase successful - Premium activated');
      } else {
        log('⚠️ Purchase processed but no active entitlement');
      }

      return CustomerInfoModel.fromRevenueCat(
        result,
        RevenueCatConstants.entitlementId,
      );
    } catch (e) {
      log('❌ Error during purchase: $e');
      rethrow;
    }
  }

  @override
  Future<CustomerInfoModel> restorePurchases() async {
    try {
      if (!_isInitialized) {
        throw Exception('RevenueCat not initialized');
      }

      log('🔄 Restoring purchases...');
      final customerInfo = await Purchases.restorePurchases();

      final hasEntitlement = customerInfo.entitlements.active
          .containsKey(RevenueCatConstants.entitlementId);

      if (hasEntitlement) {
        log('✅ Purchases restored - Premium active');
      } else {
        log('ℹ️ Purchases restored - No premium found');
      }

      return CustomerInfoModel.fromRevenueCat(
        customerInfo,
        RevenueCatConstants.entitlementId,
      );
    } catch (e) {
      log('❌ Error restoring purchases: $e');
      rethrow;
    }
  }
}
