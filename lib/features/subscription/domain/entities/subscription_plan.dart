import 'package:equatable/equatable.dart';

enum PlanType { weekly, monthly, annual }

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final PlanType type;
  final double price;
  final String description;
  final bool isPopular;
  final double savings;
  final List<String> features;
  final List<String> highlightedFeatures;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.description,
    this.isPopular = false,
    this.savings = 0,
    required this.features,
    this.highlightedFeatures = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        price,
        description,
        isPopular,
        savings,
        features,
        highlightedFeatures,
      ];
}
