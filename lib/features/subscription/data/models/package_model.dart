import 'package:memorysparks/features/subscription/domain/entities/package_entity.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PackageModel extends PackageEntity {
  final Package originalPackage;

  const PackageModel({
    required this.originalPackage,
    required super.identifier,
    required super.title,
    required super.description,
    required super.priceString,
    required super.price,
    required super.currencyCode,
  });

  factory PackageModel.fromRevenueCat(Package package) {
    return PackageModel(
      originalPackage: package,
      identifier: package.identifier,
      title: package.storeProduct.title,
      description: package.storeProduct.description,
      priceString: package.storeProduct.priceString,
      price: package.storeProduct.price,
      currencyCode: package.storeProduct.currencyCode,
    );
  }
}
