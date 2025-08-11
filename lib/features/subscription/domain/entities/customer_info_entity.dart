import 'package:equatable/equatable.dart';

class CustomerInfoEntity extends Equatable {
  final String originalAppUserId;
  final bool isPremium;
  final Map<String, String> activeEntitlements;
  final DateTime? latestExpirationDate;

  const CustomerInfoEntity({
    required this.originalAppUserId,
    required this.isPremium,
    required this.activeEntitlements,
    this.latestExpirationDate,
  });

  @override
  List<Object?> get props => [
        originalAppUserId,
        isPremium,
        activeEntitlements,
        latestExpirationDate,
      ];
}
