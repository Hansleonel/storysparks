import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/subscription_provider.dart';
import '../../domain/entities/subscription_plan.dart';
import 'package:storysparks/core/theme/app_colors.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;

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
                debugPrint(
                    '🔄 Rebuilding Paywall UI - Selected Plan: ${provider.selectedPlan?.name ?? "None"}');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Close button
                    const SizedBox(height: 56),
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
                            l10n.paywallTitle,
                            style: const TextStyle(
                              fontFamily: 'Playfair',
                              fontSize: 32,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          _BenefitItem(
                            text: l10n.paywallBenefitUnlimited,
                            icon: Icons.auto_awesome,
                          ),
                          _BenefitItem(
                            text: l10n.paywallBenefitNoAds,
                            icon: Icons.block,
                          ),
                          _BenefitItem(
                            text: l10n.paywallBenefitEarlyAccess,
                            icon: Icons.star_outline,
                          ),
                          if (provider.selectedPlan?.type == PlanType.annual)
                            _BenefitItem(
                              text: l10n.paywallBenefitAiNarration,
                              icon: Icons.record_voice_over,
                              isHighlighted: true,
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
                              child: Text(
                                l10n.paywallGetProButton,
                                style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.paywallTrialText,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
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
}

class _BenefitItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isHighlighted;

  const _BenefitItem({
    required this.text,
    required this.icon,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight:
                          isHighlighted ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isHighlighted) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.paywallNewFeatureTag,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildPlanOption(BuildContext context, SubscriptionPlan plan) {
  final isSelected = context.select<SubscriptionProvider, bool>(
    (provider) => provider.selectedPlan == plan,
  );
  final l10n = AppLocalizations.of(context)!;

  if (isSelected) {
    debugPrint('✅ Plan ${plan.name} is selected');
    debugPrint('💡 Features available: ${plan.features.join(", ")}');
  }

  String getPlanName() {
    switch (plan.type) {
      case PlanType.weekly:
        return l10n.paywallWeeklyPlan;
      case PlanType.monthly:
        return l10n.paywallMonthlyPlan;
      case PlanType.annual:
        return l10n.paywallAnnualPlan;
    }
  }

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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.paywallPopularTag,
                      style: const TextStyle(
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
                          color: AppColors.greenVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.paywallBestValueTag,
                          style: const TextStyle(
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
            getPlanName(),
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
                color: AppColors.greenVariant.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.paywallSavingsLabel(plan.savings.round()),
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  color: AppColors.greenVariant,
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
