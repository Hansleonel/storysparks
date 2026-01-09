import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'package:memorysparks/features/onboarding/presentation/pages/name_input_page.dart';
import 'package:memorysparks/features/onboarding/presentation/widgets/typewriter_text.dart';
import 'package:memorysparks/features/onboarding/presentation/widgets/memory_slideshow.dart';

/// Pantalla de mensajes de enganche con efecto máquina de escribir.
/// Flujo mejorado:
/// 1. Frase 1 → typewriter completa → pausa
/// 2. Frase 2 → typewriter completa → slideshow se activa → slideshow termina
/// 3. Frase 3 → typewriter completa → navegar a nombre
class HookMessagesPage extends StatefulWidget {
  const HookMessagesPage({super.key});

  @override
  State<HookMessagesPage> createState() => _HookMessagesPageState();
}

class _HookMessagesPageState extends State<HookMessagesPage>
    with TickerProviderStateMixin {
  int _currentMessageIndex = 0;
  bool _showSlideshow = false;
  bool _slideshowCompleted = false;
  bool _waitingForSlideshow = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Imágenes para el slideshow
  static const List<String> _memoryImages = [
    'assets/images/memory.jpeg',
    'assets/images/memory01.jpeg',
    'assets/images/memory02.jpeg',
    'assets/images/memory03.jpeg',
    'assets/images/memory04.jpeg',
    'assets/images/memory05.jpeg',
    'assets/images/memory06.jpeg',
    'assets/images/memory07.jpeg',
    'assets/images/memory08.jpeg',
    'assets/images/memory09.jpeg',
    'assets/images/memory10.jpeg',
  ];

  // Duración del slideshow (11 fotos × 700ms = 7700ms)
  static const Duration _slideshowDuration = Duration(milliseconds: 700 * 11);

  List<String> _getHookMessages(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.onboardingHookMessage1,
      l10n.onboardingHookMessage2,
      l10n.onboardingHookMessage3,
    ];
  }

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onMessageComplete() {
    final hookMessages = _getHookMessages(context);

    if (_currentMessageIndex == 1 && !_slideshowCompleted) {
      // Después de la frase 2: pausa, luego fade out, luego slideshow
      _startSlideshowSequence();
    } else if (_currentMessageIndex < hookMessages.length - 1) {
      // Pasar al siguiente mensaje normalmente (frase 1 → frase 2)
      _moveToNextMessage();
    } else {
      // Último mensaje (frase 3) completado: pausa para leer, luego navegar
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        _navigateToNameInput();
      });
    }
  }

  void _startSlideshowSequence() {
    // Pausa para leer la frase 2
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      // Fade out de la frase 2
      _fadeController.reverse().then((_) {
        if (!mounted) return;

        // Ahora sí activar slideshow (la frase ya no es visible)
        setState(() {
          _waitingForSlideshow = true;
          _showSlideshow = true;
        });

        // Esperar que el slideshow termine
        Future.delayed(_slideshowDuration, () {
          if (!mounted) return;

          setState(() {
            _slideshowCompleted = true;
            // IMPORTANTE: incrementar índice ANTES de desactivar waitingForSlideshow
            _currentMessageIndex = 2;
          });

          // Pequeña pausa después del slideshow antes de mostrar frase 3
          Future.delayed(const Duration(milliseconds: 800), () {
            if (!mounted) return;

            setState(() {
              _waitingForSlideshow = false;
            });

            // Fade in de la frase 3
            _fadeController.forward();
          });
        });
      });
    });
  }

  void _moveToNextMessage() {
    // Pausa para leer el mensaje actual
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      // Fade out
      _fadeController.reverse().then((_) {
        if (!mounted) return;

        setState(() {
          _currentMessageIndex++;
        });

        // Fade in del siguiente mensaje
        _fadeController.forward();
      });
    });
  }

  void _navigateToNameInput() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NameInputPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _navigateToNameInput();
  }

  @override
  Widget build(BuildContext context) {
    final hookMessages = _getHookMessages(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Slideshow de memorias (se activa después de frase 2)
          if (_showSlideshow)
            MemorySlideshow(
              imagePaths: _memoryImages,
              imageDuration: const Duration(milliseconds: 700),
              enableFlashEffect: true,
              overlayOpacity: 0.6,
            )
          else
            // Fondo con gradiente para mensajes sin slideshow
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF0F0F1A),
                    Colors.black,
                  ],
                ),
              ),
            ),

          // Contenido principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  // Botón saltar (sutil)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          l10n.onboardingSkip,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Espacio flexible
                  const Spacer(),

                  // Mensaje con efecto typewriter
                  // Solo mostrar si no estamos esperando el slideshow
                  if (!_waitingForSlideshow)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: TypewriterText(
                        key: ValueKey(_currentMessageIndex),
                        text: hookMessages[_currentMessageIndex],
                        charDuration: const Duration(milliseconds: 45),
                        enableHaptic: true,
                        onComplete: _onMessageComplete,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Playfair',
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Espacio flexible
                  const Spacer(),

                  // Indicador de progreso
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        hookMessages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentMessageIndex ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: index == _currentMessageIndex
                                ? AppColors.primary
                                : Colors.white.withOpacity(0.3),
                          ),
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
}
