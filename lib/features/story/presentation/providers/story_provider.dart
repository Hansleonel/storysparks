import 'package:flutter/material.dart';
import '../../domain/entities/story.dart';

class StoryProvider extends ChangeNotifier {
  bool _isExpanded = false;
  double _rating = 4.0;
  Story? _story;

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
  }

  void setRating(double rating) {
    _rating = rating;
    notifyListeners();
  }
}
