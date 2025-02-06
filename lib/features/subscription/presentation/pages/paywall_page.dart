import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../../domain/entities/subscription_plan.dart';
import 'package:storysparks/core/theme/app_colors.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image with overlay
          Positioned.fill(
            child: Image.asset(
              'assets/images/romantic.png',
              fit: BoxFit.cover,
              color: const Color(0xFF6B4BFF),
              colorBlendMode: BlendMode.overlay,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF6B4BFF).withOpacity(0.9),
                    Colors.black.withOpacity(0.92),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Consumer<SubscriptionProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Title and benefits
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Obtén más con\nStorySparks PRO',
                            style: TextStyle(
                              fontFamily: 'Playfair',
                              fontSize: 32,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          _buildBenefitItem(
                            'Historias ilimitadas y personalizadas',
                            Icons.auto_awesome,
                          ),
                          _buildBenefitItem(
                            'Sin anuncios ni interrupciones',
                            Icons.block,
                          ),
                          _buildBenefitItem(
                            'Acceso anticipado a nuevas funciones',
                            Icons.star_outline,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Subscription plans
                    Container(
                      padding: EdgeInsets.fromLTRB(24, 24, 24,
                          MediaQuery.of(context).padding.bottom + 24),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              children: provider.subscriptionPlans
                                  .map((plan) => Expanded(
                                        child: _buildPlanOption(context, plan),
                                      ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6B4BFF), AppColors.primary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement purchase flow
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Obtener PRO',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Prueba gratis por 3 días, ',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption(BuildContext context, SubscriptionPlan plan) {
    final isSelected = context.select<SubscriptionProvider, bool>(
      (provider) => provider.selectedPlan == plan,
    );

    // Definimos un color verde que combine mejor con nuestra paleta
    const bestValueColor = Color(0xFF4CAF93);

    return GestureDetector(
      onTap: () => context.read<SubscriptionProvider>().selectPlan(plan),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 22,
              child: plan.isPopular
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Popular',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : plan.type == PlanType.annual
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: bestValueColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Mejor Opción',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox(),
            ),
            const SizedBox(height: 8),
            Text(
              plan.type == PlanType.weekly
                  ? 'semanal'
                  : plan.type == PlanType.monthly
                      ? 'mensual'
                      : 'anual',
              style: TextStyle(
                fontFamily: 'Urbanist',
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${plan.price}',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            if (plan.savings > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: bestValueColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${plan.savings}%',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    color: bestValueColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
