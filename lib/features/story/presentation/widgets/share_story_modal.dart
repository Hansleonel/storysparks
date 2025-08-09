import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorysparks/core/dependency_injection/service_locator.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';
import 'package:memorysparks/features/story/presentation/providers/share_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShareStoryModal extends StatefulWidget {
  final Story story;

  const ShareStoryModal({super.key, required this.story});

  @override
  State<ShareStoryModal> createState() => _ShareStoryModalState();

  static Future<void> show(BuildContext context, Story story) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => ChangeNotifierProvider(
        create: (_) => getIt<ShareProvider>(),
        child: ShareStoryModal(story: story),
      ),
    );
  }
}

class _ShareStoryModalState extends State<ShareStoryModal> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Título
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
                    Icons.share_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.shareStory,
                  style: const TextStyle(
                    fontFamily: 'Playfair',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              l10n.shareStoryMessage(widget.story.title),
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Opciones
            _buildShareOption(
              context: context,
              icon: Icons.picture_as_pdf_outlined,
              title: l10n.shareStoryStyled,
              subtitle: l10n.shareStoryStyledSubtitle,
              color: AppColors.primary,
              onTap: () async {
                final provider = context.read<ShareProvider>();
                final success = await provider.sharePDF(
                    widget.story, 'Memory Sparks', l10n);
                if (mounted && success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.shareStorySuccess,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else if (mounted && provider.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.shareStoryError,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),

            _buildShareOption(
              context: context,
              icon: Icons.text_fields_outlined,
              title: l10n.shareStorySimple,
              subtitle: l10n.shareStorySimpleSubtitle,
              color: AppColors.accent,
              onTap: () async {
                final provider = context.read<ShareProvider>();
                final success = await provider.shareSimple(
                    widget.story, 'Memory Sparks', l10n);
                if (mounted && success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.shareStorySuccess,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else if (mounted && provider.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.shareStoryError,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
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
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
