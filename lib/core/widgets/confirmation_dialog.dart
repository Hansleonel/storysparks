import 'package:flutter/material.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/core/theme/app_theme.dart';

/// Widget reutilizable para diálogos de confirmación con diseño premium
///
/// Ejemplo de uso:
/// ```dart
/// showDialog(
///   context: context,
///   barrierDismissible: false,
///   builder: (context) => ConfirmationDialog(
///     icon: Icons.warning_rounded,
///     iconColor: Colors.red,
///     title: '¿Salir sin guardar?',
///     message: 'Esta historia se perderá...',
///     cancelText: 'Cancelar',
///     confirmText: 'Salir',
///     onConfirm: () {
///       Navigator.pop(context);
///       // Tu lógica aquí
///     },
///   ),
/// );
/// ```
class ConfirmationDialog extends StatelessWidget {
  /// Icono a mostrar en el círculo superior
  final IconData icon;

  /// Color del icono y efectos relacionados
  final Color iconColor;

  /// Título del diálogo
  final String title;

  /// Mensaje descriptivo
  final String message;

  /// Texto del botón de cancelar (opcional, default: "Cancelar")
  final String? cancelText;

  /// Texto del botón de confirmar
  final String confirmText;

  /// Callback cuando se confirma la acción
  final VoidCallback onConfirm;

  /// Callback cuando se cancela (opcional, default: cerrar diálogo)
  final VoidCallback? onCancel;

  /// Si es true, usa gradiente en el botón de confirmar
  final bool useGradient;

  /// Color de fondo del botón de confirmar (si useGradient es false)
  final Color? confirmButtonColor;

  const ConfirmationDialog({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.cancelText,
    required this.confirmText,
    required this.onConfirm,
    this.onCancel,
    this.useGradient = true,
    this.confirmButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono decorativo
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Mensaje
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Urbanist',
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Botones
            Row(
              children: [
                // Botón Cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel ?? () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      minimumSize:
                          const Size(0, 48), // Altura mínima, ancho flexible
                      backgroundColor: colors.surfaceVariant,
                      side: BorderSide(
                        color: colors.border,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      cancelText ?? 'Cancelar',
                      maxLines: 2, // Permite hasta 2 líneas
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        height: 1.2, // Line height consistente
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Botón Confirmar
                Expanded(
                  child: _buildConfirmButton(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    if (useGradient) {
      // Botón con gradiente (estilo premium)
      final color = confirmButtonColor ?? iconColor;
      return Container(
        constraints: const BoxConstraints(
          minHeight: 48, // Altura mínima, pero puede crecer
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            confirmText,
            maxLines: 2, // Permite hasta 2 líneas si es necesario
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              height: 1.2, // Line height ajustado
            ),
          ),
        ),
      );
    } else {
      // Botón sólido simple
      return ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: confirmButtonColor ?? iconColor,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          minimumSize: const Size(0, 48), // Altura mínima, ancho flexible
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          confirmText,
          maxLines: 2, // Permite hasta 2 líneas
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            color: AppColors.white,
            height: 1.2, // Line height consistente
          ),
        ),
      );
    }
  }
}
