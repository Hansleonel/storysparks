import 'package:flutter/material.dart';
import 'package:storysparks/features/story/data/datasources/story_local_datasource.dart';
import 'package:storysparks/features/story/domain/entities/story.dart';

class LibraryProvider extends ChangeNotifier {
  final _localDatasource = StoryLocalDatasource();
  List<Story> _popularStories = [];
  List<Story> _recentStories = [];
  bool _isLoading = false;

  List<Story> get popularStories => _popularStories;
  List<Story> get recentStories => _recentStories;
  bool get isLoading => _isLoading;

  Future<void> loadStories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _popularStories = await _localDatasource.getPopularStories();
      _recentStories = await _localDatasource.getRecentStories();
    } catch (e) {
      debugPrint('Error loading stories: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> incrementReadCount(int id) async {
    try {
      await _localDatasource.incrementReadCount(id);
      await loadStories(); // Recargar las historias para actualizar el orden
    } catch (e) {
      debugPrint('Error incrementing read count: $e');
    }
  }

  Future<void> deleteStory(int id) async {
    try {
      await _localDatasource.deleteStory(id);
      await loadStories(); // Recargar las historias después de eliminar
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting story: $e');
    }
  }
}
