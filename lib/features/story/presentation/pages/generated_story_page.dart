import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/story.dart';
import '../providers/story_provider.dart';

class GeneratedStoryPage extends StatelessWidget {
  final Story story;

  const GeneratedStoryPage({
    super.key,
    required this.story,
  });

  String _getHeaderImage(String genre) {
    switch (genre.toLowerCase()) {
      case 'feliz':
        return 'assets/images/happiness.png';
      case 'romántico':
        return 'assets/images/romantic.png';
      case 'nostálgico':
        return 'assets/images/nostalgic.png';
      case 'aventura':
        return 'assets/images/adventure.png';
      case 'familiar':
        return 'assets/images/familiar.png';
      case 'triste':
        return 'assets/images/sadness.png';
      default:
        return 'assets/images/nostalgic.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryProvider()..setStory(story),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined,
                    color: AppColors.textPrimary),
                onPressed: () {
                  // TODO: Implementar compartir
                },
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_outline,
                    color: AppColors.textPrimary),
                onPressed: () {
                  // TODO: Implementar guardar
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            bottom: true,
            child: SingleChildScrollView(
              controller: context.read<StoryProvider>().scrollController,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: AspectRatio(
                                aspectRatio: 2 / 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      _getHeaderImage(story.genre),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _StoryDetails(),
                          const SizedBox(height: 16),
                          const _StoryContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryDetails extends StatelessWidget {
  const _StoryDetails();

  @override
  Widget build(BuildContext context) {
    final story = context.watch<StoryProvider>().story!;
    final rating = context.watch<StoryProvider>().rating;

    return Column(
      children: [
        Text(
          'Tu Historia',
          style: const TextStyle(
            fontFamily: 'Playfair',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: AppColors.accent,
                size: 20,
              );
            }),
            const SizedBox(width: 8),
            Text(
              '${rating.toStringAsFixed(1)}/5.0',
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            _GenreChip(genre: story.genre),
            _GenreChip(genre: 'historia'),
            _GenreChip(genre: 'recuerdo'),
          ],
        ),
      ],
    );
  }
}

class _StoryContent extends StatelessWidget {
  const _StoryContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final story = provider.story!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recuerdo Original',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  story.memory,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (!provider.isExpanded)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => provider.toggleExpanded(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Empezar a leer',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          if (provider.isExpanded) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historia Generada',
                  style: TextStyle(
                    fontFamily: 'Playfair',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      // TODO: Implementar reproducción
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              key: provider.storyKey,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                story.content,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String genre;

  const _GenreChip({required this.genre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$genre',
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
