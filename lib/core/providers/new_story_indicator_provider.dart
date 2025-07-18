import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewStoryIndicatorProvider extends ChangeNotifier {
  bool _hasNewStories = false;
  String? _lastNewStoryId;

  bool get hasNewStories => _hasNewStories;
  String? get lastNewStoryId => _lastNewStoryId;

  NewStoryIndicatorProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _hasNewStories = prefs.getBool('hasNewStories') ?? false;
    _lastNewStoryId = prefs.getString('lastNewStoryId');
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasNewStories', _hasNewStories);
    if (_lastNewStoryId != null) {
      await prefs.setString('lastNewStoryId', _lastNewStoryId!);
    }
  }

  Future<void> markNewStoryAdded(String storyId) async {
    _hasNewStories = true;
    _lastNewStoryId = storyId;
    await _saveState();
    notifyListeners();
  }

  Future<void> clearNewStories() async {
    _hasNewStories = false;
    _lastNewStoryId = null;
    await _saveState();
    notifyListeners();
  }

  bool isLatestNewStory(String storyId) {
    return _lastNewStoryId == storyId && _hasNewStories;
  }
}
