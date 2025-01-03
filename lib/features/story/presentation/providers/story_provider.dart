import 'package:flutter/material.dart';
import '../../domain/entities/story.dart';
import '../../data/datasources/story_local_datasource.dart';

class StoryProvider extends ChangeNotifier {
  bool _isExpanded = false;
  double _rating = 4.0;
  Story? _story;
  final _localDatasource = StoryLocalDatasource();
  bool _isSaving = false;
  bool _isSaved = false;

  bool get isExpanded => _isExpanded;
  double get rating => _rating;
  Story? get story => _story;
  bool get isSaving => _isSaving;
  bool get isSaved => _isSaved;

  void setStory(Story story, {bool isFromLibrary = false}) {
    _story = story;
    _isSaved = isFromLibrary;
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

  Future<bool> saveStory() async {
    if (_story == null) return false;

    try {
      _isSaving = true;
      notifyListeners();

      await _localDatasource.saveStory(_story!);

      _isSaving = false;
      _isSaved = true;
      notifyListeners();
      return true;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  void unsaveStory() {
    _isSaved = false;
    notifyListeners();
  }
}
