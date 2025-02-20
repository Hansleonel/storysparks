import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storysparks/core/routes/app_routes.dart';
import 'package:storysparks/core/theme/app_colors.dart';
import 'package:storysparks/features/library/presentation/providers/library_provider.dart';
import 'package:storysparks/features/profile/presentation/providers/profile_provider.dart';
import 'package:storysparks/features/profile/presentation/widgets/review_card.dart';
import 'package:storysparks/features/story/domain/entities/story.dart';
import 'dart:io';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error al cargar el perfil',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => provider.refreshProfile(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              final profile = provider.profile;
              if (profile == null) {
                return const Center(
                  child: Text(
                    'No se encontró el perfil',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.settings_outlined,
                                    color: AppColors.textPrimary,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.settingsProfile);
                                  },
                                ),
                              ],
                            ),
                            // Profile Image
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.1),
                                  width: 4,
                                ),
                              ),
                              child: ClipOval(
                                child: profile.avatarUrl != null
                                    ? Image.network(
                                        profile.avatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            child: Icon(
                                              Icons.person,
                                              size: 60,
                                              color: AppColors.primary,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color:
                                            AppColors.primary.withOpacity(0.1),
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: AppColors.primary,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Name
                            Text(
                              provider.getDisplayName(),
                              style: TextStyle(
                                fontFamily: 'Playfair',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Username
                            Text(
                              '@${profile.username}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 18,
                                color: AppColors.accent,
                              ),
                            ),
                            if (profile.bio != null) ...[
                              const SizedBox(height: 8),
                              // Biography
                              Text(
                                profile.bio!,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 24),
                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatItem(
                                  label: 'Historias',
                                  value: '${profile.storiesGenerated}',
                                ),
                                _StatItem(
                                  label: 'Seguidores',
                                  value: '${profile.followersCount}',
                                ),
                                _StatItem(
                                  label: 'Siguiendo',
                                  value: '${profile.followingCount}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          labelStyle: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          tabs: const [
                            Tab(text: 'Historias'),
                            Tab(text: 'Reviews'),
                          ],
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    // Stories Tab
                    _StoriesTab(),
                    // Reviews Tab
                    _ReviewsTab(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _StoriesTab extends StatefulWidget {
  @override
  State<_StoriesTab> createState() => _StoriesTabState();
}

class _StoriesTabState extends State<_StoriesTab> {
  @override
  void initState() {
    super.initState();
    // Load stories when tab is created
    Future.microtask(
      () => context.read<LibraryProvider>().loadStories(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.recentStories.isEmpty) {
          return const Center(
            child: Text(
              'No hay historias aún',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: provider.recentStories.length,
          itemBuilder: (context, index) {
            final story = provider.recentStories[index];
            return _StoryGridItem(story: story);
          },
        );
      },
    );
  }
}

class _StoryGridItem extends StatefulWidget {
  final Story story;

  const _StoryGridItem({required this.story});

  @override
  State<_StoryGridItem> createState() => _StoryGridItemState();
}

class _StoryGridItemState extends State<_StoryGridItem> {
  late LibraryProvider _libraryProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _libraryProvider = context.read<LibraryProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/generated-story',
          arguments: {
            'story': widget.story,
            'isFromLibrary': true,
            'onIncrementReadCount': () async {
              if (widget.story.id != null) {
                await _libraryProvider.incrementReadCount(widget.story.id!);
              }
            },
            'onStoryStateChanged': () {
              _libraryProvider.loadStories();
            },
          },
        ).then((_) {
          // Recargar las historias cuando se regresa de la página de historia
          _libraryProvider.loadStories();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: widget.story.customImagePath != null
                ? FileImage(File(widget.story.customImagePath!))
                : AssetImage(widget.story.imageUrl) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.story.memory,
                style: const TextStyle(
                  fontFamily: 'Playfair',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ReviewCard(
            title: 'Joaquin y Raquel',
            author: 'Raquel Sánchez',
            rating: '4.5/5',
            date: '09 Jan 2025',
            review: 'Great story, i remember it like it was yesterday',
            coverUrl: 'https://picsum.photos/100/150',
          ),
        );
      },
    );
  }
}
