import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorysparks/core/providers/locale_provider.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/core/theme/app_theme.dart';
import 'package:memorysparks/l10n/app_localizations.dart';

class LanguageSelectionModal extends StatelessWidget {
  const LanguageSelectionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => const LanguageSelectionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

    // If user has explicitly selected a locale, use it; otherwise it's system default
    final isUsingSystemDefault = localeProvider.locale == null;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Drag handle
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Title with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.language_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.selectLanguage,
                  style: TextStyle(
                    fontFamily: 'Playfair',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              l10n.selectLanguageDescription,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Language options
            _LanguageOptionCard(
              locale: const Locale('en'),
              icon: '🇺🇸',
              title: 'English',
              isSelected: !isUsingSystemDefault &&
                         localeProvider.locale?.languageCode == 'en',
              onTap: () async {
                await localeProvider.setLocale(const Locale('en'));
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),

            _LanguageOptionCard(
              locale: const Locale('es'),
              icon: '🇪🇸',
              title: 'Español',
              isSelected: !isUsingSystemDefault &&
                         localeProvider.locale?.languageCode == 'es',
              onTap: () async {
                await localeProvider.setLocale(const Locale('es'));
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),

            // System default option
            _LanguageOptionCard(
              locale: null,
              icon: '🌐',
              title: l10n.systemDefault,
              isSelected: isUsingSystemDefault,
              onTap: () async {
                await localeProvider.clearLocale();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  final Locale? locale;
  final String icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionCard({
    required this.locale,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : colors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Flag/Icon emoji
                Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),

                // Language name
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : colors.textPrimary,
                    ),
                  ),
                ),

                // Checkmark when selected
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
