import 'package:flutter/foundation.dart';
import 'package:storysparks/features/profile/domain/entities/story.dart';
import 'package:storysparks/features/profile/domain/repositories/story_repository.dart';

class StoryProvider extends ChangeNotifier {
  final StoryRepository _repository;
  List<Story> _stories = [];
  bool _isLoading = false;
  String? _error;

  StoryProvider(this._repository);

  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserStories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getUserStories();
    result.fold(
      (failure) {
        _error = failure.toString();
        _stories = [];
      },
      (stories) {
        _stories = stories;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
