import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Widget que muestra un slideshow de imágenes con efecto Ken Burns y flash transitions.
class MemorySlideshow extends StatefulWidget {
  /// Lista de rutas de imágenes a mostrar.
  final List<String> imagePaths;

  /// Duración de cada imagen.
  final Duration imageDuration;

  /// Si se debe aplicar efecto de flash entre transiciones.
  final bool enableFlashEffect;

  /// Opacidad del overlay oscuro.
  final double overlayOpacity;

  /// Si debe empezar automáticamente.
  final bool autoStart;

  const MemorySlideshow({
    super.key,
    required this.imagePaths,
    this.imageDuration = const Duration(milliseconds: 800),
    this.enableFlashEffect = true,
    this.overlayOpacity = 0.4,
    this.autoStart = true,
  });

  @override
  State<MemorySlideshow> createState() => _MemorySlideshowState();
}

class _MemorySlideshowState extends State<MemorySlideshow>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _timer;
  late AnimationController _scaleController;
  late AnimationController _flashController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _flashAnimation;
  final Random _random = Random();

  // Posición de inicio para el efecto Ken Burns
  Alignment _currentAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();

    // Controlador para el efecto Ken Burns (zoom lento)
    _scaleController = AnimationController(
      duration: widget.imageDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Controlador para el efecto flash
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    ));

    _generateRandomAlignments();

    if (widget.autoStart && widget.imagePaths.isNotEmpty) {
      _startSlideshow();
    }
  }

  void _generateRandomAlignments() {
    final alignments = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.bottomRight,
      Alignment.center,
      Alignment.topCenter,
      Alignment.bottomCenter,
    ];

    _currentAlignment = alignments[_random.nextInt(alignments.length)];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  void _startSlideshow() {
    _scaleController.forward();

    _timer = Timer.periodic(widget.imageDuration, (timer) {
      // Verificar si ya mostramos todas las fotos
      if (_currentIndex >= widget.imagePaths.length - 1) {
        timer.cancel();
        return;
      }

      if (widget.enableFlashEffect) {
        _flashController.forward().then((_) {
          _flashController.reverse();
        });
      }

      setState(() {
        _currentIndex++;
        _generateRandomAlignments();
      });

      _scaleController.reset();
      _scaleController.forward();
    });
  }

  /// Inicia el slideshow manualmente.
  void start() {
    _timer?.cancel();
    _startSlideshow();
  }

  /// Detiene el slideshow.
  void stop() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen con efecto Ken Burns
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              alignment: _currentAlignment,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Image.asset(
                  widget.imagePaths[_currentIndex],
                  key: ValueKey(widget.imagePaths[_currentIndex]),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            );
          },
        ),

        // Overlay oscuro
        Container(
          color: Colors.black.withOpacity(widget.overlayOpacity),
        ),

        // Efecto flash
        if (widget.enableFlashEffect)
          AnimatedBuilder(
            animation: _flashAnimation,
            builder: (context, child) {
              return Container(
                color: Colors.white.withOpacity(_flashAnimation.value * 0.3),
              );
            },
          ),
      ],
    );
  }
}
