import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:storysparks/core/theme/app_colors.dart';
import 'package:storysparks/core/utils/cover_image_helper.dart';
import 'package:storysparks/core/utils/date_formatter.dart';
import 'package:storysparks/features/story/domain/entities/story.dart';
import 'package:storysparks/core/widgets/empty_state.dart';
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

            if (provider.popularStories.isEmpty &&
                provider.recentStories.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      AppLocalizations.of(context)!.library,
                      style: const TextStyle(
                        fontFamily: 'Playfair',
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: EmptyState(
                      message: AppLocalizations.of(context)!.noStories,
                      iconSize: 64.0,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.library,
                              style: const TextStyle(
                                fontFamily: 'Playfair',
                                fontSize: 32,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              onPressed: () => provider.toggleViewType(),
                              icon: Icon(
                                provider.viewType == LibraryViewType.grid
                                    ? Icons.view_agenda_outlined
                                    : Icons.grid_view_outlined,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                if (provider.viewType == LibraryViewType.grid) ...[
                  if (provider.popularStories.isNotEmpty)
                    const _PopularStoriesSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  if (provider.recentStories.isNotEmpty)
                    const _NewStoriesSection(),
                ] else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.timeline,
                            style: const TextStyle(
                              fontFamily: 'Playfair',
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _TimelineView(
                            stories: provider.recentStories,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
                Text(
                  AppLocalizations.of(context)!.popularStories,
                  style: const TextStyle(
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
                  child: Text(
                    AppLocalizations.of(context)!.viewAll,
                    style: const TextStyle(
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
            height: MediaQuery.of(context).size.height * 0.28,
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
                        story: story,
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
                              'onStoryStateChanged': () async {
                                if (story.id != null) {
                                  await provider.refreshStory(story.id!);
                                }
                                await provider.loadStories();
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
                Text(
                  AppLocalizations.of(context)!.newStories,
                  style: const TextStyle(
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
                  child: Text(
                    AppLocalizations.of(context)!.viewAll,
                    style: const TextStyle(
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
            height: MediaQuery.of(context).size.height * 0.28,
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
                        story: story,
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
                              'onStoryStateChanged': () async {
                                if (story.id != null) {
                                  await provider.refreshStory(story.id!);
                                }
                                await provider.loadStories();
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
}

class _StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const _StoryCard({
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.38,
        constraints: BoxConstraints(
          maxWidth: 180,
          minWidth: 140,
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image:
                        AssetImage(CoverImageHelper.getCoverImage(story.genre)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.memory,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            story.genre,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.remove_red_eye_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${story.readCount}',
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineView extends StatelessWidget {
  final List<Story> stories;

  const _TimelineView({required this.stories});

  @override
  Widget build(BuildContext context) {
    // Agrupar historias por fecha
    final groupedStories = <String, List<Story>>{};

    for (var story in stories) {
      final dateKey = DateFormatter.getFormattedDate(story.createdAt);
      groupedStories.putIfAbsent(dateKey, () => []).add(story);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedStories.length,
      itemBuilder: (context, index) {
        final dateKey = groupedStories.keys.elementAt(index);
        final storiesForDate = groupedStories[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: storiesForDate.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _TimelineCard(story: storiesForDate[index]);
              },
            ),
          ],
        );
      },
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Story story;

  const _TimelineCard({required this.story});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibraryProvider>();
    final size = MediaQuery.of(context).size;
    final imageWidth = size.width * 0.25; // 25% del ancho de la pantalla

    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
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
            'onStoryStateChanged': () async {
              if (story.id != null) {
                await provider.refreshStory(story.id!);
              }
              await provider.loadStories();
            },
          },
        );
        if (story.id != null) {
          await provider.refreshStory(story.id!);
        }
        await provider.loadStories();
      },
      child: Container(
        constraints: BoxConstraints(
          minHeight:
              size.height * 0.15, // Mínimo 15% de la altura de la pantalla
          maxHeight:
              size.height * 0.2, // Máximo 20% de la altura de la pantalla
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: imageWidth,
                child: Image.asset(
                  CoverImageHelper.getCoverImage(story.genre),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.all(size.width * 0.04), // Padding responsive
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      story.memory,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: size.width * 0.04, // Texto responsive
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: size.height * 0.008),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                            vertical: size.height * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            story.genre,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: size.width * 0.03,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.032),
                    // Barra de progreso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: story.readCount > 0 ? 1 : 0,
                        backgroundColor: AppColors.border,
                        color: AppColors.primary,
                        minHeight: 4,
                      ),
                    ),
                    SizedBox(height: size.height * 0.008),
                    // Información de progreso
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Contador de vistas
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                size: size.width * 0.04,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: size.width * 0.01),
                              Text(
                                '${story.readCount}',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: size.width * 0.03,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (story.rating > 0) ...[
                            SizedBox(width: size.width * 0.04),
                            // Rating
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: size.width * 0.04,
                                  color: AppColors.accent,
                                ),
                                SizedBox(width: size.width * 0.01),
                                Text(
                                  story.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: size.width * 0.03,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(width: size.width * 0.04),
                          // Estado de lectura
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: size.width * 0.04,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: size.width * 0.01),
                              Text(
                                story.readCount > 0
                                    ? AppLocalizations.of(context)!.completed
                                    : AppLocalizations.of(context)!.unread,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: size.width * 0.03,
                                  color: AppColors.textSecondary,
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
            ),
            // Menú de opciones
            /*SizedBox(
              width: size.width * 0.12,
              child: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                  size: size.width * 0.05,
                ),
                onPressed: () {
                  // TODO: Implementar menú de opciones
                },
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
