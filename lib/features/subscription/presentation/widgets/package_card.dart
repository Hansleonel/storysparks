import 'package:flutter/material.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/features/subscription/domain/entities/package_entity.dart';

class PackageCard extends StatelessWidget {
  final PackageEntity package;
  final bool isSelected;
  final VoidCallback onTap;

  const PackageCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPopular = _isPopularPlan(package.identifier);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Stack(
          children: [
            // Popular badge
            if (isPopular)
              Positioned(
                top: 0,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                isPopular ? 32 : 16,
                16,
                16,
              ),
              child: Row(
                children: [
                  // Radio button
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey,
                        width: 2,
                      ),
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),

                  const SizedBox(width: 16),

                  // Package info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _getPlanDisplayName(package.identifier),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_getSavingsPercentage(package.identifier) >
                                0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Ahorra ${_getSavingsPercentage(package.identifier)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPlanDescription(package.identifier),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        if (_getPerUnitPrice(package) != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _getPerUnitPrice(package)!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        package.priceString,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getPricePeriod(package.identifier),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPlanDisplayName(String identifier) {
    if (identifier.contains('weekly')) return 'Semanal';
    if (identifier.contains('monthly')) return 'Mensual';
    if (identifier.contains('annual') || identifier.contains('yearly'))
      return 'Anual';
    return identifier;
  }

  String _getPlanDescription(String identifier) {
    if (identifier.contains('weekly')) return 'Perfecto para probar';
    if (identifier.contains('monthly')) return 'Ideal para uso regular';
    if (identifier.contains('annual') || identifier.contains('yearly'))
      return 'El mejor valor';
    return 'Plan premium';
  }

  String _getPricePeriod(String identifier) {
    if (identifier.contains('weekly')) return 'por semana';
    if (identifier.contains('monthly')) return 'por mes';
    if (identifier.contains('annual') || identifier.contains('yearly'))
      return 'por año';
    return '';
  }

  bool _isPopularPlan(String identifier) {
    // Usually monthly plans are marked as popular
    return identifier.contains('monthly');
  }

  int _getSavingsPercentage(String identifier) {
    // Calculate savings based on plan type
    if (identifier.contains('monthly')) return 25; // Compared to weekly
    if (identifier.contains('annual') || identifier.contains('yearly'))
      return 50; // Compared to monthly
    return 0;
  }

  String? _getPerUnitPrice(PackageEntity package) {
    final identifier = package.identifier;

    if (identifier.contains('monthly')) {
      // Calculate weekly equivalent
      final weeklyPrice = package.price / 4;
      return '~\$${weeklyPrice.toStringAsFixed(2)} por semana';
    } else if (identifier.contains('annual') || identifier.contains('yearly')) {
      // Calculate monthly equivalent
      final monthlyPrice = package.price / 12;
      return '~\$${monthlyPrice.toStringAsFixed(2)} por mes';
    }

    return null;
  }
}
