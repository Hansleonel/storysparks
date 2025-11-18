import 'package:flutter/material.dart';
import 'package:memorysparks/core/theme/app_colors.dart';

/// Tipos de snackbar disponibles
enum SnackBarType {
  success,
  error,
  info,
  warning,
}

/// Configuración para cada tipo de snackbar
class _SnackBarConfig {
  final Color color;
  final IconData icon;

  const _SnackBarConfig({
    required this.color,
    required this.icon,
  });
}

/// Utilidad para mostrar snackbars elegantes y consistentes en toda la app
class SnackBarUtils {
  /// Muestra un snackbar personalizado
  ///
  /// [context] - BuildContext requerido para mostrar el snackbar
  /// [message] - Mensaje personalizable a mostrar
  /// [type] - Tipo de snackbar (success, error, info, warning)
  /// [duration] - Duración del snackbar (por defecto 3 segundos)
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _getConfigForType(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _CustomSnackBarContent(
          message: message,
          icon: config.icon,
          color: config.color,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Obtiene la configuración de color e icono según el tipo
  static _SnackBarConfig _getConfigForType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const _SnackBarConfig(
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case SnackBarType.error:
        return const _SnackBarConfig(
          color: AppColors.contextInsufficient,
          icon: Icons.error_rounded,
        );
      case SnackBarType.warning:
        return const _SnackBarConfig(
          color: AppColors.contextBasic,
          icon: Icons.warning_rounded,
        );
      case SnackBarType.info:
        return const _SnackBarConfig(
          color: AppColors.primary,
          icon: Icons.info_rounded,
        );
    }
  }
}

/// Widget interno para el contenido personalizado del snackbar
class _CustomSnackBarContent extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _CustomSnackBarContent({
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono con fondo blanco semi-transparente
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Mensaje
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

