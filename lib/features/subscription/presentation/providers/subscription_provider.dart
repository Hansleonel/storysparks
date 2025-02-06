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
        name: 'Plan Semanal',
        type: PlanType.weekly,
        price: weeklyPrice,
        description:
            'Para quienes quieran probar de forma intensiva a corto plazo',
        features: [
          'Generación ilimitada de historias',
          'Sin anuncios',
          'Edición de personajes',
          'Continuación de historias',
        ],
      ),
      SubscriptionPlan(
        id: 'monthly',
        name: 'Plan Mensual',
        type: PlanType.monthly,
        price: monthlyPrice,
        description: 'El plan más popular',
        isPopular: true,
        savings: monthlySavings.toDouble(),
        features: [
          'Generación ilimitada de historias',
          'Sin anuncios',
          'Edición de personajes',
          'Continuación de historias',
          'Acceso anticipado a nuevas funciones',
        ],
      ),
      SubscriptionPlan(
        id: 'annual',
        name: 'Plan Anual',
        type: PlanType.annual,
        price: annualPrice,
        description: 'Mejor valor',
        savings: annualSavings.toDouble(),
        features: [
          'Generación ilimitada de historias',
          'Sin anuncios',
          'Edición de personajes',
          'Continuación de historias',
          'Acceso anticipado a nuevas funciones',
          'Soporte prioritario',
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
