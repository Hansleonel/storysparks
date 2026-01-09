import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/core/theme/app_theme.dart';
import 'package:memorysparks/core/widgets/loading_lottie.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'package:memorysparks/features/onboarding/presentation/pages/story_preview_page.dart';
import 'package:memorysparks/features/onboarding/presentation/providers/onboarding_provider.dart';

/// Pantalla de entrada de recuerdo para el onboarding.
class MemoryInputPage extends StatefulWidget {
  const MemoryInputPage({super.key});

  @override
  State<MemoryInputPage> createState() => _MemoryInputPageState();
}

class _MemoryInputPageState extends State<MemoryInputPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _memoryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _memoryController.addListener(() {
      setState(() {});
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _memoryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectRandomMemory() {
    HapticFeedback.mediumImpact();
    final provider = context.read<OnboardingProvider>();
    final l10n = AppLocalizations.of(context)!;
    final localizedMemories = [
      l10n.presetMemory1,
      l10n.presetMemory2,
      l10n.presetMemory3,
      l10n.presetMemory4,
    ];
    final memory = provider.getRandomMemory(localizedMemories);
    _memoryController.text = memory;
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.photo_library_outlined,
                    color: colors.textPrimary),
                title: Text(
                  l10n.onboardingSelectFromGallery,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1080,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );

                  if (image != null && mounted) {
                    context
                        .read<OnboardingProvider>()
                        .setSelectedImage(image.path);
                  }
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.camera_alt_outlined, color: colors.textPrimary),
                title: Text(
                  l10n.onboardingTakePhoto,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1080,
                    maxHeight: 1080,
                    imageQuality: 85,
                  );

                  if (photo != null && mounted) {
                    context
                        .read<OnboardingProvider>()
                        .setSelectedImage(photo.path);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateStory() async {
    final l10n = AppLocalizations.of(context)!;
    if (_memoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.onboardingEmptyMemoryError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();

    final provider = context.read<OnboardingProvider>();
    provider.setMemoryText(_memoryController.text.trim());

    // Mostrar loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colors = context.appColors;
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: colors.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Padding(
              padding: EdgeInsets.all(32.0),
              child: LoadingLottie(
                showTypewriterEffect: true,
              ),
            ),
          ),
        );
      },
    );

    try {
      final story = await provider.generatePreviewStory();

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close dialog

        if (story != null) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const StoryPreviewPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        } else if (provider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final provider = context.watch<OnboardingProvider>();
    final userName = provider.data.userName;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Título con icono de magia
                  Text(
                    l10n.onboardingMagicTitle(userName),
                    style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.onboardingMagicSubtitle,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Campo de texto para el recuerdo
                  TextField(
                    controller: _memoryController,
                    focusNode: _focusNode,
                    maxLines: 6,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'El día que la conocí en el colegio...',
                      hintStyle: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    children: [
                      // Botón de foto
                      _ActionButton(
                        icon: Icons.add_photo_alternate_outlined,
                        label: l10n.onboardingPhotoLabel,
                        onTap: _pickImage,
                        isActive: provider.data.selectedImagePath != null,
                      ),

                      const SizedBox(width: 12),

                      // Botón de recuerdo aleatorio
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.shuffle_rounded,
                          label: l10n.onboardingRandomMemory,
                          onTap: _selectRandomMemory,
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),

                  // Vista previa de imagen seleccionada
                  if (provider.data.selectedImagePath != null) ...[
                    const SizedBox(height: 16),
                    _ImagePreview(
                      imagePath: provider.data.selectedImagePath!,
                      isProcessing: provider.isProcessingImage,
                      onRemove: () => context
                          .read<OnboardingProvider>()
                          .removeSelectedImage(),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Botón generar historia
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _memoryController.text.trim().isNotEmpty &&
                              !provider.isGeneratingStory
                          ? _generateStory
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withOpacity(0.4),
                        disabledForegroundColor: Colors.white.withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_stories_rounded, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            provider.isGeneratingStory
                                ? l10n.onboardingGenerating
                                : l10n.onboardingGenerateStory,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón de acción reutilizable.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isExpanded;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 16 : 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : colors.border,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.primary : colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vista previa de la imagen seleccionada.
class _ImagePreview extends StatelessWidget {
  final String imagePath;
  final bool isProcessing;
  final VoidCallback onRemove;

  const _ImagePreview({
    required this.imagePath,
    required this.isProcessing,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(11),
            ),
            child: Stack(
              children: [
                Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                ),
                if (isProcessing)
                  Container(
                    width: 80,
                    height: 80,
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.onboardingPhotoMemory,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                if (isProcessing)
                  Text(
                    l10n.onboardingAnalyzingImage,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      color: colors.textSecondary.withOpacity(0.7),
                    ),
                  )
                else
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.onboardingReadyToUse,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onRemove,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
