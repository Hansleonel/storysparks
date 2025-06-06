import 'package:flutter/material.dart';
import 'package:memorysparks/features/auth/presentation/pages/login_page.dart';
import 'package:memorysparks/features/auth/presentation/pages/register_page.dart';
import 'package:memorysparks/features/navigation/presentation/pages/main_navigation.dart';
import 'package:memorysparks/features/profile/presentation/pages/settings_page.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';
import 'package:memorysparks/features/story/presentation/pages/generated_story_page.dart';
import 'package:memorysparks/features/subscription/presentation/pages/paywall_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String settingsProfile = '/settings-profile';
  static const String generatedStory = '/generated-story';
  static const String paywall = '/paywall';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );
      case main:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        );
      case settingsProfile:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        );
      case paywall:
        return MaterialPageRoute(
          builder: (_) => const PaywallPage(),
        );
      case generatedStory:
        if (routeSettings.arguments is! Map<String, dynamic>) {
          throw ArgumentError('Arguments must be a Map<String, dynamic>');
        }
        final args = routeSettings.arguments as Map<String, dynamic>;
        final story = args['story'] as Story;
        final isFromLibrary = args['isFromLibrary'] as bool?;
        final onIncrementReadCount =
            args['onIncrementReadCount'] as VoidCallback?;
        final onStoryStateChanged =
            args['onStoryStateChanged'] as VoidCallback?;

        return MaterialPageRoute(
          builder: (_) => GeneratedStoryPage(
            story: story,
            isFromLibrary: isFromLibrary ?? false,
            onIncrementReadCount: onIncrementReadCount,
            onStoryStateChanged: onStoryStateChanged,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('404 Not Found'),
            ),
          ),
        );
    }
  }
}
