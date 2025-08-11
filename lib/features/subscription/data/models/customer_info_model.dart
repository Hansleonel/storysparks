import 'package:memorysparks/features/subscription/domain/entities/customer_info_entity.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class CustomerInfoModel extends CustomerInfoEntity {
  const CustomerInfoModel({
    required super.originalAppUserId,
    required super.isPremium,
    required super.activeEntitlements,
    super.latestExpirationDate,
  });

  factory CustomerInfoModel.fromRevenueCat(
      CustomerInfo customerInfo, String entitlementId) {
    final activeEntitlements = <String, String>{};
    final isPremium =
        customerInfo.entitlements.active.containsKey(entitlementId);

    // Convert active entitlements to map
    for (final entry in customerInfo.entitlements.active.entries) {
      activeEntitlements[entry.key] = entry.value.identifier;
    }

    // Get latest expiration date
    DateTime? latestExpiration;
    if (customerInfo.entitlements.active.isNotEmpty) {
      final expirationDates = customerInfo.entitlements.active.values
          .where((entitlement) => entitlement.expirationDate != null)
          .map((entitlement) => DateTime.parse(entitlement.expirationDate!))
          .toList();

      if (expirationDates.isNotEmpty) {
        expirationDates.sort();
        latestExpiration = expirationDates.last;
      }
    }

    return CustomerInfoModel(
      originalAppUserId: customerInfo.originalAppUserId,
      isPremium: isPremium,
      activeEntitlements: activeEntitlements,
      latestExpirationDate: latestExpiration,
    );
  }
}
