import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:memorysparks/core/dependency_injection/service_locator.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/features/home/presentation/pages/home_page.dart';
import 'package:memorysparks/features/home/presentation/providers/home_provider.dart';
import 'package:memorysparks/features/library/presentation/pages/library_page.dart';
import 'package:memorysparks/features/library/presentation/providers/library_provider.dart';
import 'package:memorysparks/features/profile/presentation/pages/profile_page.dart';
import 'package:memorysparks/features/profile/presentation/providers/profile_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
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

  void _onItemTapped(LibraryProvider provider, int index) {
    setState(() {
      if (index == 1 && _selectedIndex != index) {
        provider.loadStories();
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final libraryProvider =
        Provider.of<LibraryProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onItemTapped(libraryProvider, index),
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 0,
        backgroundColor: AppColors.white,
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bookmark_outline),
            activeIcon: const Icon(Icons.bookmark),
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
