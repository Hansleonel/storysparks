import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:memorysparks/core/theme/app_colors.dart';

/// Widget que muestra texto con efecto blur gradual para revelar parcialmente.
class BlurTextReveal extends StatelessWidget {
  /// El texto completo a mostrar.
  final String text;

  /// Porcentaje del texto que se muestra sin blur (0.0 a 1.0).
  final double revealPercentage;

  /// Callback cuando se toca la zona con blur.
  final VoidCallback? onTapBlurred;

  /// Estilo del texto.
  final TextStyle? style;

  /// Texto del botón CTA.
  final String ctaText;

  const BlurTextReveal({
    super.key,
    required this.text,
    this.revealPercentage = 0.3,
    this.onTapBlurred,
    this.style,
    this.ctaText = 'Continuar leyendo',
  });

  @override
  Widget build(BuildContext context) {
    // Calcular el punto de corte basado en el porcentaje
    final cutoffIndex = (text.length * revealPercentage).round();
    final visibleText = text.substring(0, cutoffIndex);
    final blurredText = text.substring(cutoffIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto visible
        Text(
          visibleText,
          style: style,
        ),

        // Texto con blur gradual
        if (blurredText.isNotEmpty) ...[
          Stack(
            children: [
              // Texto base (blur)
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.0, 0.7],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Text(
                    blurredText,
                    style: style,
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Overlay interactivo con CTA
              Positioned.fill(
                child: GestureDetector(
                  onTap: onTapBlurred,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botón CTA
          Center(
            child: GestureDetector(
              onTap: onTapBlurred,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ctaText,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
