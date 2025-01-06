import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storysparks/core/theme/app_colors.dart';
import 'package:storysparks/core/utils/cover_image_helper.dart';
import '../providers/library_provider.dart';
import 'package:storysparks/core/routes/app_routes.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LibraryPageContent();
  }
}

class _LibraryPageContent extends StatelessWidget {
  const _LibraryPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<LibraryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mi Biblioteca',
                          style: TextStyle(
                            fontFamily: 'Playfair',
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                if (provider.popularStories.isNotEmpty)
                  const _PopularStoriesSection(),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                if (provider.recentStories.isNotEmpty)
                  const _NewStoriesSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PopularStoriesSection extends StatelessWidget {
  const _PopularStoriesSection();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historias Populares 🔥',
                  style: TextStyle(
                    fontFamily: 'Playfair',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implementar ver todas las historias populares
                  },
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: Consumer<LibraryProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.popularStories.length,
                  itemBuilder: (context, index) {
                    final story = provider.popularStories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _StoryCard(
                        title: story.memory,
                        author: story.genre,
                        coverImage: _getCoverImage(story.genre),
                        readCount: story.readCount,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.generatedStory,
                            arguments: {
                              'story': story,
                              'isFromLibrary': true,
                              'onIncrementReadCount': () async {
                                if (story.id != null) {
                                  await provider.incrementReadCount(story.id!);
                                }
                              },
                              'onStoryStateChanged': () {
                                provider.loadStories();
                              },
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getCoverImage(String genre) {
    return CoverImageHelper.getCoverImage(genre);
  }
}

class _NewStoriesSection extends StatelessWidget {
  const _NewStoriesSection();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nuevas Historias 🎁',
                  style: TextStyle(
                    fontFamily: 'Playfair',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implementar ver todas las historias nuevas
                  },
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: Consumer<LibraryProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.recentStories.length,
                  itemBuilder: (context, index) {
                    final story = provider.recentStories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _StoryCard(
                        title: story.memory,
                        author: story.genre,
                        coverImage: _getCoverImage(story.genre),
                        readCount: story.readCount,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.generatedStory,
                            arguments: {
                              'story': story,
                              'isFromLibrary': true,
                              'onIncrementReadCount': () async {
                                if (story.id != null) {
                                  await provider.incrementReadCount(story.id!);
                                }
                              },
                              'onStoryStateChanged': () {
                                provider.loadStories();
                              },
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getCoverImage(String genre) {
    return CoverImageHelper.getCoverImage(genre);
  }
}

class _StoryCard extends StatelessWidget {
  final String title;
  final String author;
  final String coverImage;
  final int readCount;
  final VoidCallback onTap;

  const _StoryCard({
    required this.title,
    required this.author,
    required this.coverImage,
    required this.onTap,
    this.readCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 160,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      coverImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (readCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.remove_red_eye,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$readCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              author,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
