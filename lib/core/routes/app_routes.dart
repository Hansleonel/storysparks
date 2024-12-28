import 'package:flutter/material.dart';
import 'package:storysparks/features/auth/presentation/pages/login_page.dart';
import 'package:storysparks/features/navigation/presentation/pages/main_navigation.dart';
import 'package:storysparks/features/story/domain/entities/story.dart';
import 'package:storysparks/features/story/presentation/pages/generated_story_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String main = '/main';
  static const String generatedStory = '/generated-story';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case main:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        );
      case generatedStory:
        return MaterialPageRoute(
          builder: (_) => GeneratedStoryPage(
            story: settings.arguments as Story,
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
