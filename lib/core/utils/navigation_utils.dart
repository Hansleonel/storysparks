import 'package:flutter/material.dart';

class NavigationUtils {
  static Future<T?> slideUpTransition<T>({
    required BuildContext context,
    required Widget page,
    Object? arguments,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        settings: RouteSettings(arguments: arguments),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuart;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: duration,
      ),
    );
  }

  static Future<T?> fadeTransition<T>({
    required BuildContext context,
    required Widget page,
    Object? arguments,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        settings: RouteSettings(arguments: arguments),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: duration,
      ),
    );
  }
}

// Extension method para una sintaxis más elegante
extension NavigationExtensions on BuildContext {
  Future<T?> pushWithSlideUp<T>(Widget page, {Object? arguments}) {
    return NavigationUtils.slideUpTransition(
      context: this,
      page: page,
      arguments: arguments,
    );
  }

  Future<T?> pushWithFade<T>(Widget page, {Object? arguments}) {
    return NavigationUtils.fadeTransition(
      context: this,
      page: page,
      arguments: arguments,
    );
  }
}
