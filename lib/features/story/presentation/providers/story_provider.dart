import 'package:flutter/material.dart';
import '../../domain/entities/story.dart';

class StoryProvider extends ChangeNotifier {
  bool _isExpanded = false;
  double _rating = 4.0;
  Story? _story;
  final ScrollController scrollController = ScrollController();
  final GlobalKey storyKey = GlobalKey();

  bool get isExpanded => _isExpanded;
  double get rating => _rating;
  Story? get story => _story;

  void setStory(Story story) {
    _story = story;
    notifyListeners();
  }

  void toggleExpanded() {
    _isExpanded = true;
    notifyListeners();

    // Esperar a que se construya el widget
    Future.delayed(const Duration(milliseconds: 100), () {
      final context = storyKey.currentContext;
      if (context != null) {
        // Obtener la posición del widget
        final box = context.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero);

        // Scroll hasta la posición con animación
        scrollController.animateTo(
          offset.dy - 100, // Restamos 100 para dar un poco de espacio arriba
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void setRating(double rating) {
    _rating = rating;
    notifyListeners();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
