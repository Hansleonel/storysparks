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
        if (settings.arguments is! Map<String, dynamic>) {
          throw ArgumentError('Arguments must be a Map<String, dynamic>');
        }
        final args = settings.arguments as Map<String, dynamic>;
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
