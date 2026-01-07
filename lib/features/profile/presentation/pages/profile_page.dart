import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'package:memorysparks/core/routes/app_routes.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/core/theme/app_theme.dart';
import 'package:memorysparks/features/library/presentation/providers/library_provider.dart';
import 'package:memorysparks/features/profile/presentation/providers/profile_provider.dart';
import 'package:memorysparks/features/profile/presentation/widgets/review_card.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';
import 'package:memorysparks/features/subscription/presentation/providers/subscription_provider.dart';
import 'dart:io';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
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
                        AppLocalizations.of(context)!.errorLoadingProfile,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => provider.refreshProfile(),
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                );
              }

              final profile = provider.profile;
              if (profile == null) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.noProfileFound,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: colors.textSecondary,
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
                                  icon: Icon(
                                    Icons.settings_outlined,
                                    color: colors.textPrimary,
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
                                            child: const Icon(
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
                                        child: const Icon(
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
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Username
                            Text(
                              '@${profile.username}',
                              style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 18,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Premium Status Badge - use SubscriptionProvider as source of truth
                            Consumer<SubscriptionProvider>(
                              builder: (context, subscriptionProvider, child) {
                                return _PremiumStatusBadge(
                                    isPremium: subscriptionProvider.isPremium);
                              },
                            ),
                            if (profile.bio != null) ...[
                              const SizedBox(height: 8),
                              // Biography
                              Text(
                                profile.bio!,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: colors.textSecondary,
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
                                  label: AppLocalizations.of(context)!.stories,
                                  value: '${profile.storiesGenerated}',
                                ),
                                _StatItem(
                                  label:
                                      AppLocalizations.of(context)!.followers,
                                  value: '${profile.followersCount}',
                                ),
                                _StatItem(
                                  label:
                                      AppLocalizations.of(context)!.following,
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
                        context,
                        TabBar(
                          labelColor: AppColors.primary,
                          unselectedLabelColor: colors.textSecondary,
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
                          tabs: [
                            Tab(text: AppLocalizations.of(context)!.stories),
                            Tab(text: AppLocalizations.of(context)!.reviews),
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
    final colors = context.appColors;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final BuildContext _context;

  _SliverAppBarDelegate(this._context, this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colors = _context.appColors;
    return Container(
      color: colors.background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
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
    final colors = context.appColors;
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.recentStories.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noStoriesYet,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 16,
                color: colors.textSecondary,
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

class _PremiumStatusBadge extends StatelessWidget {
  final bool isPremium;

  const _PremiumStatusBadge({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    if (isPremium) {
      // Premium user badge - elegant golden design
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFFD4AF37), const Color(0xFFB8860B)]
                : [const Color(0xFFFFD700), const Color(0xFFFFA500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isDark ? const Color(0xFFD4AF37) : const Color(0xFFFFD700))
                  .withOpacity(isDark ? 0.2 : 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.of(context)!.alreadyPremiumTitle,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      // Non-premium user button - using paywall colors
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.paywall);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B4BFF), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B4BFF).withOpacity(isDark ? 0.2 : 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.diamond_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.upgradeToPremium,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
