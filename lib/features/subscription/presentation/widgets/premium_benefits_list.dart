import 'package:flutter/material.dart';
import 'package:memorysparks/core/theme/app_colors.dart';

class PremiumBenefitsList extends StatelessWidget {
  const PremiumBenefitsList({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      _Benefit(
        icon: Icons.auto_stories,
        title: 'Historias Ilimitadas',
        description: 'Crea tantas historias como quieras',
      ),
      _Benefit(
        icon: Icons.block,
        title: 'Sin Anuncios',
        description: 'Disfruta sin interrupciones',
      ),
      _Benefit(
        icon: Icons.edit,
        title: 'Edición de Personajes',
        description: 'Personaliza completamente tus personajes',
      ),
      _Benefit(
        icon: Icons.auto_fix_high,
        title: 'Continuación de Historias',
        description: 'Extiende tus historias con IA',
      ),
      _Benefit(
        icon: Icons.flash_on,
        title: 'Acceso Anticipado',
        description: 'Nuevas funciones antes que nadie',
      ),
      _Benefit(
        icon: Icons.support_agent,
        title: 'Soporte Prioritario',
        description: 'Ayuda rápida cuando la necesites',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Beneficios Premium:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...benefits.map((benefit) => _buildBenefitItem(benefit)),
      ],
    );
  }

  Widget _buildBenefitItem(_Benefit benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              benefit.icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  benefit.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit {
  final IconData icon;
  final String title;
  final String description;

  _Benefit({
    required this.icon,
    required this.title,
    required this.description,
  });
}
