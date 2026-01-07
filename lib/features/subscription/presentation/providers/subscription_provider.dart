import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/subscription/domain/entities/customer_info_entity.dart';
import 'package:memorysparks/features/subscription/domain/entities/offering_entity.dart';
import 'package:memorysparks/features/subscription/domain/entities/package_entity.dart';
import 'package:memorysparks/features/subscription/domain/usecases/check_premium_status_usecase.dart';
import 'package:memorysparks/features/subscription/domain/usecases/get_offerings_usecase.dart';
import 'package:memorysparks/features/subscription/domain/usecases/initialize_revenuecat_usecase.dart';
import 'package:memorysparks/features/subscription/domain/usecases/logout_revenuecat_usecase.dart';
import 'package:memorysparks/features/subscription/domain/usecases/purchase_package_usecase.dart';
import 'package:memorysparks/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:memorysparks/features/subscription/domain/usecases/set_customer_info_listener_usecase.dart';
import 'package:memorysparks/features/subscription/domain/usecases/remove_customer_info_listener_usecase.dart';

enum SubscriptionState { initial, loading, loaded, purchasing, error }

class SubscriptionProvider extends ChangeNotifier {
  final InitializeRevenueCatUseCase initializeRevenueCatUseCase;
  final LogoutRevenueCatUseCase logoutRevenueCatUseCase;
  final CheckPremiumStatusUseCase checkPremiumStatusUseCase;
  final GetOfferingsUseCase getOfferingsUseCase;
  final PurchasePackageUseCase purchasePackageUseCase;
  final RestorePurchasesUseCase restorePurchasesUseCase;
  final SetCustomerInfoListenerUseCase setCustomerInfoListenerUseCase;
  final RemoveCustomerInfoListenerUseCase removeCustomerInfoListenerUseCase;

  SubscriptionProvider({
    required this.initializeRevenueCatUseCase,
    required this.logoutRevenueCatUseCase,
    required this.checkPremiumStatusUseCase,
    required this.getOfferingsUseCase,
    required this.purchasePackageUseCase,
    required this.restorePurchasesUseCase,
    required this.setCustomerInfoListenerUseCase,
    required this.removeCustomerInfoListenerUseCase,
  });

  SubscriptionState _state = SubscriptionState.initial;
  SubscriptionState get state => _state;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  List<OfferingEntity> _offerings = [];
  List<OfferingEntity> get offerings => _offerings;

  PackageEntity? _selectedPackage;
  PackageEntity? get selectedPackage => _selectedPackage;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CustomerInfoEntity? _customerInfo;
  CustomerInfoEntity? get customerInfo => _customerInfo;

  int _selectedPlanIndex = 1; // Monthly selected by default
  int get selectedPlanIndex => _selectedPlanIndex;

  /// Get sorted packages in the correct order: Weekly, Monthly, Yearly
  List<PackageEntity> get sortedPackages {
    final packages =
        _offerings.expand((offering) => offering.availablePackages).toList();

    // Sort packages in the desired order
    packages.sort((a, b) {
      int getOrder(String identifier) {
        if (identifier.toLowerCase().contains('weekly')) return 0;
        if (identifier.toLowerCase().contains('monthly')) return 1;
        if (identifier.toLowerCase().contains('yearly') ||
            identifier.toLowerCase().contains('annual')) return 2;
        return 3; // Unknown packages go last
      }

      return getOrder(a.identifier).compareTo(getOrder(b.identifier));
    });

    return packages;
  }

  /// Get enriched package data with UI properties
  List<Map<String, dynamic>> get enrichedPackages {
    return sortedPackages.map((package) {
      final identifier = package.identifier.toLowerCase();
      String title = 'Plan';
      int savings = 0;
      bool isPopular = false;

      if (identifier.contains('weekly')) {
        title = 'Weekly';
      } else if (identifier.contains('monthly')) {
        title = 'Monthly';
        savings = 25;
        isPopular = true;
      } else if (identifier.contains('yearly') ||
          identifier.contains('annual')) {
        title = 'Yearly';
        savings = 67;
      }

      return {
        'package': package,
        'title': title,
        'savings': savings,
        'isPopular': isPopular,
        'identifier': package.identifier,
        'priceString': package.priceString,
      };
    }).toList();
  }

  /// Get currently selected package
  PackageEntity? get currentSelectedPackage {
    final packages = sortedPackages;
    if (_selectedPlanIndex < packages.length) {
      return packages[_selectedPlanIndex];
    }
    return null;
  }

  /// Initialize RevenueCat with user ID
  Future<void> initializeWithUser(String userId) async {
    try {
      log('🔧 Initializing RevenueCat for user: $userId');
      _setState(SubscriptionState.loading);

      final result = await initializeRevenueCatUseCase(userId);

      result.fold(
        (failure) {
          log('❌ Failed to initialize RevenueCat: ${failure.toString()}');
          _setError(failure.toString());
        },
        (_) async {
          log('✅ RevenueCat initialized successfully');

          // Set up automatic listener for subscription changes
          _setupCustomerInfoListener();

          // Load initial data
          await _loadInitialData();
        },
      );
    } catch (e) {
      log('💥 Exception during RevenueCat initialization: $e');
      _setError(e.toString());
    }
  }

  /// Set up listener for automatic customer info updates
  void _setupCustomerInfoListener() {
    log('👂 Setting up automatic subscription status listener');
    // This will be called automatically by RevenueCat when:
    // - App comes to foreground (every 5 minutes if in foreground)
    // - After purchase/restore
    // - When subscription status changes
    setCustomerInfoListenerUseCase((customerInfo) {
      log('🔔 Subscription status updated automatically');
      log('💎 New premium status: ${customerInfo.isPremium}');

      // Update local state
      _customerInfo = customerInfo;
      _isPremium = customerInfo.isPremium;

      // Notify all listeners (including FreemiumProvider)
      notifyListeners();
    });
  }

  @override
  void dispose() {
    // Clean up listener when provider is disposed
    removeCustomerInfoListenerUseCase();
    super.dispose();
  }

  /// Logout from RevenueCat
  Future<void> logoutRevenueCat() async {
    try {
      log('🔐 Logging out from RevenueCat');
      final result = await logoutRevenueCatUseCase(NoParams());

      result.fold(
        (failure) =>
            log('⚠️ Error logging out from RevenueCat: ${failure.toString()}'),
        (_) {
          log('✅ RevenueCat logout successful');
          _resetState();
        },
      );
    } catch (e) {
      log('💥 Exception during RevenueCat logout: $e');
    }
  }

  /// Check current premium status
  Future<void> checkPremiumStatus() async {
    try {
      final result = await checkPremiumStatusUseCase(NoParams());

      result.fold(
        (failure) {
          log('❌ Failed to check premium status: ${failure.toString()}');
          _isPremium = false;
        },
        (isPremium) {
          log('💎 Premium status: $isPremium');
          _isPremium = isPremium;
        },
      );

      notifyListeners();
    } catch (e) {
      log('💥 Exception checking premium status: $e');
      _isPremium = false;
      notifyListeners();
    }
  }

  /// Load available offerings
  Future<void> loadOfferings() async {
    try {
      _setState(SubscriptionState.loading);

      final result = await getOfferingsUseCase(NoParams());

      result.fold(
        (failure) {
          log('❌ Failed to load offerings: ${failure.toString()}');
          _setError(failure.toString());
        },
        (offerings) {
          log('📦 Loaded ${offerings.length} offerings');
          _offerings = offerings;
          _setState(SubscriptionState.loaded);

          // Auto-select first package if available
          if (offerings.isNotEmpty &&
              offerings.first.availablePackages.isNotEmpty) {
            _selectedPackage = offerings.first.availablePackages.first;
            log('🎯 Auto-selected package: ${_selectedPackage!.identifier}');
          }
        },
      );
    } catch (e) {
      log('💥 Exception loading offerings: $e');
      _setError(e.toString());
    }
  }

  /// Purchase selected package
  Future<bool> purchasePackage(PackageEntity package) async {
    try {
      log('💳 Starting purchase for: ${package.identifier}');
      _setState(SubscriptionState.purchasing);

      final result = await purchasePackageUseCase(package);

      return result.fold(
        (failure) {
          log('❌ Purchase failed: ${failure.toString()}');
          _setError(failure.toString());
          return false;
        },
        (customerInfo) {
          log('🎉 Purchase successful!');
          _customerInfo = customerInfo;
          _isPremium = customerInfo.isPremium;
          _setState(SubscriptionState.loaded);
          return true;
        },
      );
    } catch (e) {
      log('💥 Exception during purchase: $e');
      _setError(e.toString());
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      log('🔄 Restoring purchases...');
      _setState(SubscriptionState.loading);

      final result = await restorePurchasesUseCase(NoParams());

      return result.fold(
        (failure) {
          log('❌ Restore failed: ${failure.toString()}');
          _setError(failure.toString());
          return false;
        },
        (customerInfo) {
          log('✅ Purchases restored successfully');
          _customerInfo = customerInfo;
          _isPremium = customerInfo.isPremium;
          _setState(SubscriptionState.loaded);
          return true;
        },
      );
    } catch (e) {
      log('💥 Exception during restore: $e');
      _setError(e.toString());
      return false;
    }
  }

  /// Select a package for purchase (legacy method)
  void selectPackage(PackageEntity package) {
    log('🎯 Selected package: ${package.identifier} - ${package.priceString}');
    _selectedPackage = package;
    notifyListeners();
  }

  /// Select a plan by index
  void selectPlanByIndex(int index) {
    final packages = sortedPackages;
    if (index >= 0 && index < packages.length) {
      _selectedPlanIndex = index;
      _selectedPackage = packages[index];
      log('🎯 Selected plan [$index]: ${_selectedPackage!.identifier} - ${_selectedPackage!.priceString}');
      notifyListeners();
    }
  }

  /// Purchase currently selected package
  Future<bool> purchaseCurrentPackage() async {
    final package = currentSelectedPackage;
    if (package == null) {
      log('❌ No package selected for purchase');
      return false;
    }
    return await purchasePackage(package);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Load initial data after initialization
  Future<void> _loadInitialData() async {
    await Future.wait([
      checkPremiumStatus(),
      loadOfferings(),
    ]);
  }

  /// Set state and notify listeners
  void _setState(SubscriptionState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  /// Set error state
  void _setError(String error) {
    _state = SubscriptionState.error;
    _errorMessage = error;
    notifyListeners();
  }

  /// Reset state to initial
  void _resetState() {
    _state = SubscriptionState.initial;
    _isPremium = false;
    _offerings = [];
    _selectedPackage = null;
    _errorMessage = null;
    _customerInfo = null;
    notifyListeners();
  }
}
