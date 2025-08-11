import 'package:memorysparks/features/subscription/data/models/package_model.dart';
import 'package:memorysparks/features/subscription/domain/entities/offering_entity.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class OfferingModel extends OfferingEntity {
  const OfferingModel({
    required super.identifier,
    required super.serverDescription,
    required super.availablePackages,
  });

  factory OfferingModel.fromRevenueCat(Offering offering) {
    final packages = offering.availablePackages
        .map((package) => PackageModel.fromRevenueCat(package))
        .toList();

    return OfferingModel(
      identifier: offering.identifier,
      serverDescription: offering.serverDescription,
      availablePackages: packages,
    );
  }
}
