import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:memorysparks/features/subscription/domain/entities/package_entity.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({
    super.key,
    this.onPurchaseSuccess,
    this.sourceScreen,
  });

  final VoidCallback? onPurchaseSuccess;
  final String? sourceScreen;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  // ✅ Removed _selectedPlanIndex - now managed by provider

  @override
  void initState() {
    super.initState();

    // Load offerings when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().loadOfferings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image with overlay (like paywall_page.dart)
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
              builder: (context, subscriptionProvider, child) {
                // Show premium content if user is already premium
                if (subscriptionProvider.isPremium) {
                  return _buildPremiumContent(context);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Close button
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _buildCloseButton(),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Title and benefits
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.unlockMemorySparks,
                              style: const TextStyle(
                                fontFamily: 'Playfair',
                                fontSize: 32,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            _buildBenefitItem(
                              AppLocalizations.of(context)!
                                  .paywallBenefitUnlimited,
                              Icons.auto_awesome,
                            ),
                            _buildBenefitItem(
                              AppLocalizations.of(context)!
                                  .paywallBenefitAiNarrationShort,
                              Icons.record_voice_over,
                              isHighlighted: true,
                            ),
                            _buildBenefitItem(
                              AppLocalizations.of(context)!
                                  .paywallBenefitContinueStory,
                              Icons.history_edu,
                            ),
                            _buildBenefitItem(
                              AppLocalizations.of(context)!
                                  .paywallBenefitPhotos,
                              Icons.photo_library,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Subscription plans section
                    Container(
                      padding: EdgeInsets.fromLTRB(24, 24, 24,
                          MediaQuery.of(context).padding.bottom + 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Plans
                          _buildPricingPlans(subscriptionProvider),
                          const SizedBox(height: 20),

                          // Continue button
                          _buildContinueButton(subscriptionProvider),
                          const SizedBox(height: 12),

                          // Restore button
                          _buildRestoreButton(subscriptionProvider),

                          // Apple required links
                          _buildAppleRequiredLinks(),

                          // Apple subscription terms (compact)
                          _buildCompactTerms(),
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

  Widget _buildBenefitItem(String text, IconData icon,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: Colors.white,
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
                      color: const Color(0xFFEC4899),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEC4899).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.newTag,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        color: Colors.white,
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

  Widget _buildPricingPlans(SubscriptionProvider subscriptionProvider) {
    // Use REAL data from RevenueCat offerings, no mock data
    if (subscriptionProvider.offerings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.loadingSubscriptionPlans,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontFamily: 'Urbanist',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Use enriched packages from provider (includes sorting and UI properties)
    final enrichedPackages = subscriptionProvider.enrichedPackages;

    // 📊 LOG: Debug packages from provider
    log('🔍 ENRICHED PACKAGES DEBUG:');
    log('📦 Total packages found: ${enrichedPackages.length}');
    for (int i = 0; i < enrichedPackages.length; i++) {
      final enrichedPackage = enrichedPackages[i];
      final package = enrichedPackage['package'] as PackageEntity;
      log('  [$i] ${enrichedPackage['title']}: ${package.identifier} (${enrichedPackage['priceString']})');
      log('      Savings: ${enrichedPackage['savings']}%, Popular: ${enrichedPackage['isPopular']}');
    }

    return IntrinsicHeight(
      child: Row(
        children: enrichedPackages.asMap().entries.map((entry) {
          final index = entry.key;
          final enrichedPackage = entry.value;
          final package = enrichedPackage['package'] as PackageEntity;
          final isSelected = subscriptionProvider.selectedPlanIndex == index;

          // ✅ Get UI properties from provider
          final title = enrichedPackage['title'] as String;
          final savings = enrichedPackage['savings'] as int;
          final isPopular = enrichedPackage['isPopular'] as bool;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // ✅ Use provider method to select plan
                subscriptionProvider.selectPlanByIndex(index);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6B4BFF).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6B4BFF)
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: 22,
                      child: isPopular
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.popularTag,
                                style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : title == 'Yearly'
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.bestValueTag,
                                    style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        color: isSelected
                            ? const Color(0xFF6B4BFF)
                            : const Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      package.priceString,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFF6B4BFF)
                            : const Color(0xFF111827),
                      ),
                    ),
                    if (savings > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Save $savings%',
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContinueButton(SubscriptionProvider subscriptionProvider) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B4BFF), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4BFF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: (subscriptionProvider.state == SubscriptionState.loading ||
                subscriptionProvider.state == SubscriptionState.purchasing)
            ? null
            : () => _handlePurchase(subscriptionProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: subscriptionProvider.state == SubscriptionState.loading ||
                subscriptionProvider.state == SubscriptionState.purchasing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                AppLocalizations.of(context)!.getPro,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildRestoreButton(SubscriptionProvider subscriptionProvider) {
    return TextButton(
      onPressed: (subscriptionProvider.state == SubscriptionState.loading ||
              subscriptionProvider.state == SubscriptionState.purchasing)
          ? null
          : () => _handleRestore(subscriptionProvider),
      child: Text(
        AppLocalizations.of(context)!.restorePurchases,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 14,
          fontFamily: 'Urbanist',
        ),
      ),
    );
  }

  Widget _buildAppleRequiredLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLinkButton(
          AppLocalizations.of(context)!.termsOfService,
          'https://memorysparks.app/#terms',
        ),
        Container(
          width: 1,
          height: 16,
          color: const Color(0xFF6B7280),
        ),
        _buildLinkButton(
          AppLocalizations.of(context)!.privacyPolicy,
          'https://memorysparks.app/#privacy',
        ),
      ],
    );
  }

  Widget _buildLinkButton(String text, String url) {
    return TextButton(
      onPressed: () => _launchUrl(url),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
          fontFamily: 'Urbanist',
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildCompactTerms() {
    return Text(
      AppLocalizations.of(context)!.subscriptionTermsText,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF6B7280),
        fontFamily: 'Urbanist',
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCloseButton() {
    return IconButton(
      icon: const Icon(Icons.close, color: Colors.white),
      onPressed: _handleClosePress,
    );
  }

  void _handleClosePress() {
    // Show confirmation modal when user tries to close
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => _ExitConfirmationModal(
        onConfirmExit: () {
          Navigator.pop(modalContext); // Close modal
          _navigateToMain(); // Smart navigation (popUntil or push)
        },
        onCancel: () => Navigator.pop(modalContext),
        onGetPremium: () {
          Navigator.pop(modalContext); // Close modal, stay on paywall
        },
      ),
    );
  }

  Widget _buildPremiumContent(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Close button at top right
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => _handleContinuePress(context),
            ),
          ),
          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star,
                    size: 100,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.alreadyPremiumTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.alreadyPremiumMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleContinuePress(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.continueButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePurchase(SubscriptionProvider subscriptionProvider) async {
    HapticFeedback.mediumImpact();

    // ✅ Use provider method to purchase current package
    try {
      log('💳 Starting purchase process...');
      final success = await subscriptionProvider.purchaseCurrentPackage();

      if (mounted && success && subscriptionProvider.isPremium) {
        log('🎉 Purchase successful!');

        // Show success dialog first, then navigate
        await _showSuccessDialogAndNavigate();

        // Call success callback
        widget.onPurchaseSuccess?.call();
      } else if (mounted && !success) {
        // Show error from provider
        final errorMessage = subscriptionProvider.errorMessage ??
            'Purchase failed. Please try again.';
        _showErrorMessage(errorMessage);
      }
    } catch (e) {
      log('💥 Purchase exception: $e');
      if (mounted) {
        _showErrorMessage('Error processing purchase: ${e.toString()}');
      }
    }
  }

  void _handleRestore(SubscriptionProvider subscriptionProvider) async {
    HapticFeedback.lightImpact();

    try {
      log('🔄 Starting restore process...');
      await subscriptionProvider.restorePurchases();

      if (mounted) {
        if (subscriptionProvider.isPremium) {
          log('✅ Restore successful with premium!');
          // Show success dialog and navigate to main
          await _showSuccessDialogAndNavigate();
        } else {
          log('ℹ️ Restore completed but no premium found');
          _showInfoDialog('No purchases found to restore.');
        }
      }
    } catch (e) {
      log('💥 Restore exception: $e');
      if (mounted) {
        _showErrorMessage('Error restoring purchases: ${e.toString()}');
      }
    }
  }

  void _handleContinuePress(BuildContext context) {
    if (widget.sourceScreen != null) {
      // Handle specific navigation based on source (e.g., from story generation)
      Navigator.of(context).pop(true);
    } else {
      // Use smart navigation for all other cases
      _navigateToMain();
    }
  }

  /// Shows success dialog and navigates to main after user dismisses it.
  /// Uses popUntil when coming from within the app (natural animation),
  /// and pushNamedAndRemoveUntil when coming from onboarding (no stack).
  Future<void> _showSuccessDialogAndNavigate() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(dialogContext)!.welcomeToPremium,
          style: const TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
        ),
        content: Text(
          AppLocalizations.of(dialogContext)!.premiumAccessMessage,
          style: const TextStyle(color: Colors.white70, fontFamily: 'Urbanist'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              AppLocalizations.of(dialogContext)!.continueButton,
              style: const TextStyle(
                  color: Color(0xFF6366F1), fontFamily: 'Urbanist'),
            ),
          ),
        ],
      ),
    );

    // After dialog is closed, navigate appropriately
    if (mounted) {
      _navigateToMain();
    }
  }

  /// Smart navigation: uses popUntil if MainNavigation is in the stack,
  /// otherwise pushes to main (for onboarding flow).
  void _navigateToMain() {
    // Check if there's a route to pop to (meaning we came from within the app)
    if (Navigator.of(context).canPop()) {
      // Pop all the way back to the first route (MainNavigation)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      // No route to pop to (onboarding flow) - push to main
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/main',
        (route) => false,
      );
    }
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.error,
          style: const TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70, fontFamily: 'Urbanist'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.ok,
              style:
                  TextStyle(color: Color(0xFF6366F1), fontFamily: 'Urbanist'),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.information,
          style: const TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70, fontFamily: 'Urbanist'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.ok,
              style:
                  TextStyle(color: Color(0xFF6366F1), fontFamily: 'Urbanist'),
            ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }
}

/// Modal de confirmación al cerrar el paywall.
class _ExitConfirmationModal extends StatelessWidget {
  final VoidCallback onConfirmExit;
  final VoidCallback onCancel;
  final VoidCallback? onGetPremium;

  const _ExitConfirmationModal({
    required this.onConfirmExit,
    required this.onCancel,
    this.onGetPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Icono de advertencia
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 36,
              color: Color(0xFFF59E0B),
            ),
          ),

          const SizedBox(height: 20),

          // Título
          const Text(
            '¿Te perderás de la continuación?',
            style: TextStyle(
              fontFamily: 'Playfair',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Descripción con beneficios
          const Text(
            'Con Premium también puedes:',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Lista de beneficios
          const _BenefitItem(
            icon: Icons.record_voice_over_rounded,
            text: 'Generar 1 audio diario de tus historias',
          ),
          const SizedBox(height: 10),
          const _BenefitItem(
            icon: Icons.history_edu_rounded,
            text: 'Continuar donde lo dejaste',
          ),
          const SizedBox(height: 10),
          const _BenefitItem(
            icon: Icons.all_inclusive_rounded,
            text: 'Historias ilimitadas',
          ),

          const SizedBox(height: 28),

          // Botón primario - Obtener Premium
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onGetPremium?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Obtener Premium',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Botón secundario - Salir
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onConfirmExit();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Salir de todas formas',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }
}
