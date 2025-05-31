import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:memorysparks/core/theme/app_colors.dart';

class ContinueStoryDialog extends StatefulWidget {
  const ContinueStoryDialog({super.key});

  @override
  State<ContinueStoryDialog> createState() => _ContinueStoryDialogState();
}

class _ContinueStoryDialogState extends State<ContinueStoryDialog> {
  int _selectedOption = 0; // 0 = automatic, 1 = custom
  final TextEditingController _directionController = TextEditingController();

  @override
  void dispose() {
    _directionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              localizations.continueStoryMode,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Automatic option
            _buildOptionCard(
              title: localizations.automaticContinuation,
              description: localizations.automaticContinuationDescription,
              icon: Icons.auto_mode,
              isSelected: _selectedOption == 0,
              onTap: () => setState(() => _selectedOption = 0),
            ),

            const SizedBox(height: 16),

            // Custom option
            _buildOptionCard(
              title: localizations.customContinuation,
              description: localizations.customContinuationDescription,
              icon: Icons.edit,
              isSelected: _selectedOption == 1,
              onTap: () => setState(() => _selectedOption = 1),
            ),

            // Custom direction input (only shown when custom is selected)
            if (_selectedOption == 1) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _directionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: localizations.writeYourDirection,
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Urbanist',
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Text(
                      localizations.cancel,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedOption == 0) {
                        // Automatic continuation
                        Navigator.of(context).pop({'mode': 'automatic'});
                      } else {
                        // Custom continuation
                        final direction = _directionController.text.trim();
                        if (direction.isNotEmpty) {
                          Navigator.of(context).pop({
                            'mode': 'custom',
                            'direction': direction,
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _selectedOption == 0
                          ? localizations.continueAutomatically
                          : localizations.continueWithDirection,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Urbanist',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
