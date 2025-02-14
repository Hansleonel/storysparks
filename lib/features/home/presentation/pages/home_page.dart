import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storysparks/core/routes/app_routes.dart';
import 'package:storysparks/core/theme/app_colors.dart';
import '../providers/home_provider.dart';
import 'package:storysparks/core/constants/genre_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<HomeProvider>().unfocusMemoryInput(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _Header(),
                  SizedBox(height: 32),
                  _MemoryInput(),
                  SizedBox(height: 32),
                  _GenreSection(),
                  SizedBox(height: 32),
                  _ProtagonistSection(),
                  SizedBox(height: 40),
                  _GenerateButton(),
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
        const SizedBox(height: 16),
        Consumer<HomeProvider>(
          builder: (context, provider, child) {
            return Row(
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
                            child: Builder(
                              builder: (context) {
                                final file = File(provider.selectedImagePath!);
                                debugPrint(
                                    'Loading image from path: ${file.path}');
                                debugPrint('File exists: ${file.existsSync()}');
                                return Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  width: 56,
                                  height: 56,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Error loading image: $error');
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
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.memoryImage,
                              style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
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
          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            label: Row(
              children: [
                Icon(
                  genre.icon,
                  size: 18,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
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
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    color:
                        isSelected ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.white,
            selectedColor: AppColors.primary,
            onSelected: (bool selected) {
              provider.setSelectedGenre(
                  selected ? GenreConstants.toStringValue(genre) : '');
            },
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProtagonistSection extends StatelessWidget {
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
}

class _GenerateButton extends StatelessWidget {
  const _GenerateButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return ElevatedButton(
            onPressed: provider.isGenerateEnabled
                ? () async {
                    try {
                      final story = await provider.generateStory();
                      if (context.mounted) {
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
            child: Text(
              AppLocalizations.of(context)!.generateStory,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          );
        },
      ),
    );
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
