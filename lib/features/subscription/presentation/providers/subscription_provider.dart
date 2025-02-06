import 'package:flutter/foundation.dart';
import '../../domain/entities/subscription_plan.dart';

class SubscriptionProvider extends ChangeNotifier {
  List<SubscriptionPlan> get subscriptionPlans => [
        SubscriptionPlan(
          id: 'weekly',
          name: 'Plan Semanal',
          type: PlanType.weekly,
          price: 3.99,
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
          price: 9.99,
          description: 'El plan más popular',
          isPopular: true,
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
          price: 59.99,
          description: 'Mejor valor',
          savings: 50,
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
