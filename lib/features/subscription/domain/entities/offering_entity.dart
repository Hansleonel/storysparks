import 'package:equatable/equatable.dart';
import 'package:memorysparks/features/subscription/domain/entities/package_entity.dart';

class OfferingEntity extends Equatable {
  final String identifier;
  final String serverDescription;
  final List<PackageEntity> availablePackages;

  const OfferingEntity({
    required this.identifier,
    required this.serverDescription,
    required this.availablePackages,
  });

  @override
  List<Object> get props => [
        identifier,
        serverDescription,
        availablePackages,
      ];
}
