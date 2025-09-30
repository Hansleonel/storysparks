import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:memorysparks/features/subscription/presentation/pages/paywall_screen.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memorysparks/core/routes/app_routes.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import '../providers/home_provider.dart';
import 'package:memorysparks/core/constants/genre_constants.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'package:memorysparks/core/widgets/loading_lottie.dart';
import 'package:memorysparks/features/story/presentation/widgets/author_style_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<HomeProvider>().unfocusMemoryInput(),
      child: const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(),
                  SizedBox(height: 32),
                  _MemoryInput(),
                  SizedBox(height: 32),
                  _GenreSection(),
                  SizedBox(height: 32),
                  // _ProtagonistSection(),
                  //SizedBox(height: 40),
                  _GenerateButton(),
                  // SizedBox(height: 16),
                  //_TemporaryPaywallButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryInput extends StatelessWidget {
  const _MemoryInput();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HomeProvider>();
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: provider.memoryController,
          focusNode: provider.memoryFocusNode,
          autofocus: false,
          maxLines: 5,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: l10n.shareMemoryHint,
            hintStyle: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        _WordCounter(
          controller: provider.memoryController,
          focusNode: provider.memoryFocusNode,
        ),
        const SizedBox(height: 16),
        Consumer<HomeProvider>(
          builder: (context, provider, child) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ImagePickerButton(),
                const SizedBox(width: 12),
                if (provider.selectedImagePath?.isNotEmpty ?? false) ...[
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(11),
                            ),
                            child: Stack(
                              children: [
                                Builder(
                                  builder: (context) {
                                    final file =
                                        File(provider.selectedImagePath!);
                                    debugPrint(
                                        'Loading image from path: ${file.path}');
                                    debugPrint(
                                        'File exists: ${file.existsSync()}');
                                    return Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                      width: 56,
                                      height: 56,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        debugPrint(
                                            'Error loading image: $error');
                                        return Container(
                                          width: 56,
                                          height: 56,
                                          color: AppColors.border,
                                          child: const Icon(
                                            Icons.error_outline,
                                            color: AppColors.textSecondary,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                if (provider.isProcessingImage)
                                  Container(
                                    width: 56,
                                    height: 56,
                                    color: Colors.black.withOpacity(0.5),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.white),
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
                                  l10n.memoryImage,
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (provider.isProcessingImage)
                                  Text(
                                    'Analizando imagen...',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 12,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                if (provider.imageDescription != null)
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => provider.removeSelectedImage(),
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        l10n.optionalPhotoMessage,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ImagePickerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        icon: const Icon(Icons.add_photo_alternate_outlined),
        color: AppColors.primary,
        onPressed: () {
          final provider = context.read<HomeProvider>();
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
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
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined),
                      title: Text(
                        l10n.selectFromGallery,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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

                        if (image != null) {
                          provider.setSelectedImage(image.path);
                        } else {
                          debugPrint('No image selected');
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined),
                      title: Text(
                        l10n.takePhoto,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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

                        if (photo != null) {
                          provider.setSelectedImage(photo.path);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GenreSection extends StatelessWidget {
  const _GenreSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.genreTitle,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16),
        _GenreChips(),
        SizedBox(height: 12),
        _AuthorStyleOption(),
      ],
    );
  }
}

class _GenreChips extends StatelessWidget {
  const _GenreChips();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: Genre.values.map((genre) {
          return _GenreChip(
            genre: genre,
          );
        }).toList(),
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final Genre genre;

  const _GenreChip({
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          final isSelected =
              provider.selectedGenre == GenreConstants.toStringValue(genre);
          return GestureDetector(
            onTap: () {
              // Feedback haptic sutil para selección
              HapticFeedback.selectionClick();
              provider.setSelectedGenre(
                  isSelected ? '' : GenreConstants.toStringValue(genre));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      genre.icon,
                      key: ValueKey('${genre.key}_${isSelected}'),
                      size: 18,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                    child: Text(
                      genre.key == 'genreHappy'
                          ? l10n.genreHappy
                          : genre.key == 'genreSad'
                              ? l10n.genreSad
                              : genre.key == 'genreRomantic'
                                  ? l10n.genreRomantic
                                  : genre.key == 'genreNostalgic'
                                      ? l10n.genreNostalgic
                                      : genre.key == 'genreAdventure'
                                          ? l10n.genreAdventure
                                          : l10n.genreFamily,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// TODO: in case we want to add a protagonist section
/* class _ProtagonistSection extends StatelessWidget {
  const _ProtagonistSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.theProtagonistWillBe,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border,
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/profile.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Shahzaib',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
                color: AppColors.textSecondary,
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {},
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}*/

class _GenerateButton extends StatelessWidget {
  const _GenerateButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return LoadingLottie(
              message: AppLocalizations.of(context)!.generatingStory,
            );
          }

          return ElevatedButton(
            onPressed: provider.isGenerateEnabled
                ? () async {
                    // Feedback haptic para acción importante
                    HapticFeedback.mediumImpact();
                    try {
                      final story = await provider.generateStory();
                      if (context.mounted) {
                        provider.resetState();
                        Navigator.pushNamed(
                          context,
                          AppRoutes.generatedStory,
                          arguments: {
                            'story': story,
                            'isFromLibrary': false,
                          },
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_stories,
                  color: AppColors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.generateStory,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WordCounter extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _WordCounter({
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([controller, focusNode]),
            builder: (context, child) {
              final text = controller.text.trim();
              final wordCount = text.isEmpty
                  ? 0
                  : text
                      .split(RegExp(r'\s+'))
                      .where((word) => word.isNotEmpty)
                      .length;
              final isActive = focusNode.hasFocus;

              return _buildContextQualityIndicator(wordCount, isActive);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContextQualityIndicator(int wordCount, bool isActive) {
    String message;
    Color color;
    IconData? icon;

    // Siempre mostrar advertencia si no hay suficientes palabras
    if (!isActive) {
      // Si tiene suficientes palabras pero no está enfocado, mostrar discreto
      message = '$wordCount palabras';
      color = AppColors.textSecondary.withOpacity(0.6);
      icon = Icons.edit_outlined;
    } else {
      if (wordCount == 0) {
        message = 'Comparte tu memoria...';
        color = AppColors.textSecondary.withOpacity(0.6);
        icon = Icons.edit_outlined;
      } else if (wordCount <= 5) {
        message = '$wordCount palabras';
        color = AppColors.textSecondary.withOpacity(0.8);
        icon = Icons.edit_outlined;
      } else if (wordCount < 20) {
        message = '$wordCount palabras - Añade más detalles';
        color = AppColors.contextInsufficient;
        icon = Icons.edit_outlined;
      } else if (wordCount < 30) {
        message = '$wordCount palabras ✓ Buen inicio';
        color = AppColors.contextBasic;
        icon = Icons.check_circle_outline;
      } else if (wordCount < 50) {
        message = '$wordCount palabras ✓ Historia rica';
        color = AppColors.contextGood;
        icon = Icons.thumb_up_outlined;
      } else if (wordCount < 75) {
        message = '$wordCount palabras ✓ Muy detallada';
        color = AppColors.contextRich;
        icon = Icons.auto_awesome_outlined;
      } else {
        message = '$wordCount palabras ✓ ¡Excepcional!';
        color = AppColors.contextExceptional;
        icon = Icons.stars_outlined;
      }
    }

    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorStyleOption extends StatelessWidget {
  const _AuthorStyleOption();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        final hasStyle = provider.authorStyle?.isNotEmpty ?? false;

        return GestureDetector(
          onTap: () async {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (context) => AuthorStyleDialog(
                currentAuthor: provider.authorStyleType == 'author'
                    ? provider.authorStyle
                    : null,
                currentBook: provider.authorStyleType == 'book'
                    ? provider.authorStyle
                    : null,
              ),
            );

            if (result != null) {
              if (result['clear'] == true) {
                provider.clearAuthorStyle();
              } else if (result['text'] != null && result['type'] != null) {
                provider.setAuthorStyle(result['text'], result['type']);
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasStyle ? Icons.auto_stories : Icons.tune,
                  size: 16,
                  color: hasStyle
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  hasStyle
                      ? _getStyleDisplayText(provider)
                      : AppLocalizations.of(context)!.authorStyleAdvancedConfig,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w500,
                    color: hasStyle
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStyleDisplayText(HomeProvider provider) {
    if (provider.authorStyleType == 'author') {
      final author = provider.authorStyle!;
      return author.length > 20
          ? '✨ Estilo de ${author.substring(0, 15)}...'
          : '✨ Estilo de $author';
    } else if (provider.authorStyleType == 'book') {
      final book = provider.authorStyle!;
      return book.length > 20
          ? '📖 Estilo de ${book.substring(0, 15)}...'
          : '📖 Estilo de $book';
    } else {
      return '✨ Estilo personalizado';
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final userName = context.select<HomeProvider, String?>(
      (provider) => provider.userName,
    );
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border,
                  width: 2,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/profile.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    l10n.hello(userName ?? '...'),
                    style: const TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Text(
                  l10n.goodMorning,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              debugPrint('🔔 Notifications tapped');
              // TODO: in case we want to see the paywall using a modal
              /* ModalUtils.showFullScreenModal(
                context: context,
                child: const PaywallPage(),
              ); */
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* class _TemporaryPaywallButton extends StatelessWidget {
  const _TemporaryPaywallButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PaywallScreen(
                sourceScreen: 'home_test',
              ),
            ),
          );
        },
        icon: const Icon(
          Icons.star_border,
          color: Colors.orange,
          size: 20,
        ),
        label: const Text(
          '🚀 TEST: Abrir Paywall Apple',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.orange,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.withOpacity(0.1),
          foregroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.withOpacity(0.3)),
          ),
          elevation: 0,
        ),
      ),
    );
  }
} */
