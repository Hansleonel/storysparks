import 'dart:io';
import 'package:flutter/material.dart';

/// Widget que muestra una imagen con efecto parallax 3D.
class ParallaxImage extends StatefulWidget {
  /// Ruta de la imagen (puede ser asset o file path).
  final String imagePath;

  /// Si la imagen es un asset o un archivo.
  final bool isAsset;

  /// Intensidad del efecto parallax (0.0 a 1.0).
  final double parallaxIntensity;

  /// Duración de la animación.
  final Duration animationDuration;

  /// Altura del contenedor.
  final double height;

  /// Border radius.
  final double borderRadius;

  const ParallaxImage({
    super.key,
    required this.imagePath,
    this.isAsset = true,
    this.parallaxIntensity = 0.3,
    this.animationDuration = const Duration(seconds: 4),
    this.height = 300,
    this.borderRadius = 24,
  });

  @override
  State<ParallaxImage> createState() => _ParallaxImageState();
}

class _ParallaxImageState extends State<ParallaxImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _alignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _alignmentAnimation,
          builder: (context, child) {
            return OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: Transform.scale(
                scale: 1.0 + (widget.parallaxIntensity * 0.2),
                child: widget.isAsset
                    ? Image.asset(
                        widget.imagePath,
                        fit: BoxFit.cover,
                        alignment: _alignmentAnimation.value,
                        width: double.infinity,
                        height: widget.height * 1.3,
                      )
                    : Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
                        alignment: _alignmentAnimation.value,
                        width: double.infinity,
                        height: widget.height * 1.3,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
