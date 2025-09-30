import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorysparks/l10n/app_localizations.dart';
import 'package:memorysparks/core/dependency_injection/service_locator.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/features/home/presentation/pages/home_page.dart';
import 'package:memorysparks/features/home/presentation/providers/home_provider.dart';
import 'package:memorysparks/features/library/presentation/pages/library_page.dart';
import 'package:memorysparks/features/library/presentation/providers/library_provider.dart';
import 'package:memorysparks/features/profile/presentation/pages/profile_page.dart';
import 'package:memorysparks/features/profile/presentation/providers/profile_provider.dart';
import 'package:memorysparks/core/providers/new_story_indicator_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Navigation constants
  static const int _homeIndex = 0;
  static const int _libraryIndex = 1;
  static const int _profileIndex = 2;
  static const Duration _notificationClearDelay = Duration(seconds: 3);

  int _selectedIndex = _homeIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ChangeNotifierProvider(
        create: (_) => getIt<HomeProvider>(),
        child: const HomePage(),
      ),
      const LibraryPage(),
      ChangeNotifierProvider(
        create: (_) => getIt<ProfileProvider>(),
        child: const ProfilePage(),
      ),
    ];
  }

  void _onItemTapped(LibraryProvider libraryProvider,
      NewStoryIndicatorProvider newStoryIndicatorProvider, int index) {
    setState(() {
      if (index == _libraryIndex && _selectedIndex != index) {
        libraryProvider.loadStories();
        // Limpiar el indicador de historias nuevas después de un delay para que se vea la etiqueta
        Future.delayed(_notificationClearDelay, () {
          newStoryIndicatorProvider.clearNewStories();
        });
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider =
        Provider.of<LibraryProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NewStoryIndicatorProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) =>
            _onItemTapped(libraryProvider, notificationProvider, index),
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  // Styling constants
  static const double _shadowBlurRadius = 10.0;
  static const Offset _shadowOffset = Offset(0, -5);
  static const double _shadowOpacity = 0.1;
  static const double _navigationBarElevation = 0.0;
  static const double _selectedLabelFontSize = 12.0;
  static const double _unselectedLabelFontSize = 12.0;
  static const FontWeight _selectedLabelWeight = FontWeight.w600;
  static const FontWeight _unselectedLabelWeight = FontWeight.w500;
  static const String _fontFamily = 'Urbanist';

  // Notification indicator constants
  static const double _notificationIndicatorSize = 8.0;
  static const double _notificationIndicatorTopPosition = 0.0;
  static const double _notificationIndicatorRightPosition = 0.0;

  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_shadowOpacity),
            blurRadius: _shadowBlurRadius,
            offset: _shadowOffset,
          ),
        ],
      ),
      child: BottomNavigationBar(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: _navigationBarElevation,
        backgroundColor: AppColors.white,
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: _selectedLabelWeight,
          fontSize: _selectedLabelFontSize,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: _unselectedLabelWeight,
          fontSize: _unselectedLabelFontSize,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Consumer<NewStoryIndicatorProvider>(
              builder: (context, notificationProvider, _) {
                return Stack(
                  children: [
                    const Icon(Icons.bookmark_outline),
                    if (notificationProvider.hasNewStories)
                      Positioned(
                        top: _notificationIndicatorTopPosition,
                        right: _notificationIndicatorRightPosition,
                        child: Container(
                          width: _notificationIndicatorSize,
                          height: _notificationIndicatorSize,
                          decoration: const BoxDecoration(
                            color: AppColors.newIndicator,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            activeIcon: Consumer<NewStoryIndicatorProvider>(
              builder: (context, notificationProvider, _) {
                return Stack(
                  children: [
                    const Icon(Icons.bookmark),
                    if (notificationProvider.hasNewStories)
                      Positioned(
                        top: _notificationIndicatorTopPosition,
                        right: _notificationIndicatorRightPosition,
                        child: Container(
                          width: _notificationIndicatorSize,
                          height: _notificationIndicatorSize,
                          decoration: const BoxDecoration(
                            color: AppColors.newIndicator,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: l10n.library,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
