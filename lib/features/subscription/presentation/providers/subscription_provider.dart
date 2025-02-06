import 'package:flutter/foundation.dart';
import '../../domain/entities/subscription_plan.dart';

class SubscriptionProvider extends ChangeNotifier {
  List<SubscriptionPlan> get subscriptionPlans {
    const weeklyPrice = 3.99;
    const monthlyPrice = 9.99;
    const annualPrice = 59.99;

    // Calculamos el ahorro del plan mensual comparado con el semanal
    final monthlySavings =
        ((weeklyPrice * 4 - monthlyPrice) / (weeklyPrice * 4) * 100).round();

    // Calculamos el ahorro del plan anual comparado con el mensual
    final annualSavings =
        ((monthlyPrice * 12 - annualPrice) / (monthlyPrice * 12) * 100).round();

    return [
      SubscriptionPlan(
        id: 'weekly',
        name: 'weekly',
        type: PlanType.weekly,
        price: weeklyPrice,
        description: 'weekly_description',
        features: const [
          'unlimited_stories',
          'no_ads',
          'character_editing',
          'story_continuation',
        ],
      ),
      SubscriptionPlan(
        id: 'monthly',
        name: 'monthly',
        type: PlanType.monthly,
        price: monthlyPrice,
        description: 'monthly_description',
        isPopular: true,
        savings: monthlySavings.toDouble(),
        features: const [
          'unlimited_stories',
          'no_ads',
          'character_editing',
          'story_continuation',
          'early_access',
        ],
      ),
      SubscriptionPlan(
        id: 'annual',
        name: 'annual',
        type: PlanType.annual,
        price: annualPrice,
        description: 'annual_description',
        savings: annualSavings.toDouble(),
        features: const [
          'unlimited_stories',
          'no_ads',
          'character_editing',
          'story_continuation',
          'early_access',
          'priority_support',
        ],
      ),
    ];
  }

  SubscriptionPlan? _selectedPlan;
  SubscriptionPlan? get selectedPlan => _selectedPlan;

  void selectPlan(SubscriptionPlan plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPlan = null;
    notifyListeners();
  }
}
