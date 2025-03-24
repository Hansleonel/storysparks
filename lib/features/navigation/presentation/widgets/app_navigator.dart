import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storysparks/features/auth/presentation/pages/login_page.dart';
import 'package:storysparks/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:storysparks/features/onboarding/presentation/providers/onboarding_provider.dart';

/// Widget que maneja la navegación inicial basada en el estado de onboarding
class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para escuchar cambios en el estado de onboarding
    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
        // Verificamos si el usuario ha completado el onboarding
        if (provider.hasCompletedOnboarding) {
          return const LoginPage();
        } else {
          return const OnboardingPage();
        }
      },
    );
  }
}
