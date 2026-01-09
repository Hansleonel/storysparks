import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/core/theme/app_theme.dart';
import 'package:memorysparks/features/onboarding/presentation/pages/quick_sign_in_page.dart';
import 'package:memorysparks/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:memorysparks/features/onboarding/presentation/widgets/blur_text_reveal.dart';

/// Pantalla de preview de la historia generada durante el onboarding.
class StoryPreviewPage extends StatefulWidget {
  const StoryPreviewPage({super.key});

  @override
  State<StoryPreviewPage> createState() => _StoryPreviewPageState();
}

class _StoryPreviewPageState extends State<StoryPreviewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _parallaxAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    // Animación parallax: movimiento lento de izquierda a derecha
    _parallaxAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));

    _animController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateToSignIn() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const QuickSignInPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  String _getEmotionImage(String genre) {
    switch (genre.toLowerCase()) {
      case 'happy':
        return 'assets/images/happiness.png';
      case 'sad':
        return 'assets/images/sadness.png';
      case 'romantic':
        return 'assets/images/romantic.png';
      case 'nostalgic':
        return 'assets/images/nostalgic.png';
      case 'adventure':
        return 'assets/images/adventure.png';
      case 'family':
        return 'assets/images/familiar.png';
      default:
        return 'assets/images/romantic.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final provider = context.watch<OnboardingProvider>();
    final story = provider.data.generatedStory;

    if (story == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Determinar qué imagen usar
    final hasCustomImage = provider.data.selectedImagePath != null;
    final imagePath = hasCustomImage
        ? provider.data.selectedImagePath!
        : _getEmotionImage(story.genre);

    return Scaffold(
      backgroundColor: colors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Header con imagen parallax
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: colors.background,
              leading: const SizedBox(),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen con efecto parallax
                    AnimatedBuilder(
                      animation: _parallaxAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _parallaxAnimation.value * 50,
                            0,
                          ),
                          child: Transform.scale(
                            scale: 1.15,
                            child: hasCustomImage
                                ? Image.file(
                                    File(imagePath),
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        );
                      },
                    ),

                    // Gradiente inferior
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 150,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              colors.background,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido de la historia
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la historia
                    Text(
                      story.title,
                      style: TextStyle(
                        fontFamily: 'Playfair',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Badge del género
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        story.genre,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Contenido de la historia con blur
                    BlurTextReveal(
                      text: story.content,
                      revealPercentage: 0.35,
                      onTapBlurred: _navigateToSignIn,
                      ctaText: 'Continuar leyendo',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: colors.textPrimary,
                        height: 1.8,
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
