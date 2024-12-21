import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storysparks/core/theme/app_colors.dart';
import '../providers/home_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

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
            hintText:
                'Comparte un recuerdo especial, como tu primera bicicleta o ese viaje inolvidable con la familia...',
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
        Row(
          children: [
            _ImagePickerButton(),
            const SizedBox(width: 12),
            if (context.select((HomeProvider p) => p.selectedImagePath != null))
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
                        child: Image.file(
                          File(context.select(
                              (HomeProvider p) => p.selectedImagePath!)),
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Imagen del recuerdo',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () =>
                            context.read<HomeProvider>().removeSelectedImage(),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ImagePickerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        onPressed: () async {
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1080,
            maxHeight: 1080,
            imageQuality: 85,
          );

          if (image != null && context.mounted) {
            context.read<HomeProvider>().setSelectedImage(image.path);
          }
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
      children: const [
        Text(
          'El recuerdo es...',
          style: TextStyle(
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
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _GenreChip(label: 'Feliz', icon: Icons.sentiment_very_satisfied),
          _GenreChip(label: 'Nostálgico', icon: Icons.favorite),
          _GenreChip(label: 'Aventura', icon: Icons.explore),
          _GenreChip(label: 'Familiar', icon: Icons.family_restroom),
          _GenreChip(label: 'Divertido', icon: Icons.celebration),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _GenreChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          final isSelected = provider.selectedGenre == label;
          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            label: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
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
              provider.setSelectedGenre(selected ? label : '');
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
        const Text(
          'El protagonista será...',
          style: TextStyle(
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
          return ElevatedButton(
            onPressed: provider.isGenerateEnabled
                ? () {
                    // TODO: Implementar la generación de la historia
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
            child: const Text(
              'Generar historia',
              style: TextStyle(
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
                Text(
                  'Hello, Shahzaib',
                  style: TextStyle(
                    fontFamily: 'Playfair',
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Good morning',
                  style: TextStyle(
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
        Container(
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
      ],
    );
  }
}
