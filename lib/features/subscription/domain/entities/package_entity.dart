import 'package:equatable/equatable.dart';

class PackageEntity extends Equatable {
  final String identifier;
  final String title;
  final String description;
  final String priceString;
  final double price;
  final String currencyCode;

  const PackageEntity({
    required this.identifier,
    required this.title,
    required this.description,
    required this.priceString,
    required this.price,
    required this.currencyCode,
  });

  @override
  List<Object> get props => [
        identifier,
        title,
        description,
        priceString,
        price,
        currencyCode,
      ];
}
