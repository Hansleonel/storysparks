import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/core/theme/app_theme.dart';
import 'package:memorysparks/core/routes/app_routes.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'package:memorysparks/features/auth/presentation/providers/auth_provider.dart';
import 'package:memorysparks/features/subscription/presentation/providers/freemium_provider.dart';
import 'package:memorysparks/features/onboarding/presentation/providers/onboarding_provider.dart';

/// Página simplificada de autenticación para el onboarding.
/// Solo muestra Apple y Google sign-in, luego navega al paywall.
class QuickSignInPage extends StatefulWidget {
  const QuickSignInPage({super.key});

  @override
  State<QuickSignInPage> createState() => _QuickSignInPageState();
}

class _QuickSignInPageState extends State<QuickSignInPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 200), () {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleAppleSignIn() async {
    HapticFeedback.mediumImpact();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithApple();

    if (success && mounted) {
      await _onSignInSuccess(authProvider);
    } else if (mounted && authProvider.error != null) {
      _showError(authProvider.error!);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    HapticFeedback.mediumImpact();

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      await _onSignInSuccess(authProvider);
    } else if (mounted && authProvider.error != null) {
      _showError(authProvider.error!);
    }
  }

  Future<void> _onSignInSuccess(AuthProvider authProvider) async {
    final user = authProvider.currentUser;

    if (user != null) {
      // Inicializar FreemiumProvider
      await context.read<FreemiumProvider>().initialize(user.id);

      // Transferir historia del onboarding si existe
      final onboardingProvider = context.read<OnboardingProvider>();
      if (onboardingProvider.data.generatedStory != null) {
        await onboardingProvider.transferStoryToUser(user.id);
      }

      // Marcar onboarding como completado
      await onboardingProvider.completeOnboarding();

      authProvider.resetLoadingState();

      if (mounted) {
        // Navegar al paywall
        Navigator.of(context).pushReplacementNamed(AppRoutes.paywall);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final authProvider = context.watch<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Icono o ilustración
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Título
                  Text(
                    l10n.onboardingSaveStory,
                    style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Subtítulo
                  Text(
                    l10n.onboardingSaveStorySubtitle,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 2),

                  // Botones de autenticación
                  if (Platform.isIOS) ...[
                    // Apple Sign In
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: SignInWithAppleButton(
                        text: l10n.onboardingContinueWithApple,
                        style: SignInWithAppleButtonStyle.black,
                        borderRadius: BorderRadius.circular(14),
                        onPressed:
                            authProvider.isLoading ? () {} : _handleAppleSignIn,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Google Sign In
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed:
                          authProvider.isLoading ? null : _handleGoogleSignIn,
                      icon: Image.asset(
                        'assets/images/google_icon.png',
                        height: 24,
                        width: 24,
                      ),
                      label: Text(
                        l10n.onboardingContinueWithGoogle,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.surface,
                        foregroundColor: colors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: colors.border),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Loading indicator
                  if (authProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),

                  // Texto de términos
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      l10n.onboardingTerms,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        color: colors.textSecondary.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
