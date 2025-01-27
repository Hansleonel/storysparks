import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/story.dart';
import '../../domain/usecases/delete_story_usecase.dart';
import '../../domain/usecases/update_story_rating_usecase.dart';
import '../../domain/usecases/continue_story_usecase.dart';
import '../../domain/repositories/story_repository.dart';

class StoryProvider extends ChangeNotifier {
  final UpdateStoryRatingUseCase _updateRatingUseCase;
  final DeleteStoryUseCase _deleteStoryUseCase;
  final StoryRepository _repository;
  final ContinueStoryUseCase _continueStoryUseCase;

  bool _isExpanded = false;
  bool _isMemoryExpanded = false;
  double _rating = 4.0;
  Story? _story;
  bool _isSaving = false;
  bool _isSaved = false;
  Story? _currentStory;
  bool _isLoading = false;
  String? _error;

  StoryProvider({
    required UpdateStoryRatingUseCase updateRatingUseCase,
    required DeleteStoryUseCase deleteStoryUseCase,
    required StoryRepository repository,
    required ContinueStoryUseCase continueStoryUseCase,
  })  : _updateRatingUseCase = updateRatingUseCase,
        _deleteStoryUseCase = deleteStoryUseCase,
        _repository = repository,
        _continueStoryUseCase = continueStoryUseCase;

  bool get isExpanded => _isExpanded;
  bool get isMemoryExpanded => _isMemoryExpanded;
  double get rating => _rating;
  Story? get story => _story;
  bool get isSaving => _isSaving;
  bool get isSaved => _isSaved;
  Story? get currentStory => _currentStory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setStory(Story story, {bool isFromLibrary = false}) {
    _story = story;
    _isSaved = isFromLibrary;
    if (isFromLibrary) {
      _rating = story.rating;
    }
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
    if (_story != null) {
      try {
        final storyToSave = _story!.copyWith(rating: _rating);
        final id = await _repository.saveStory(storyToSave);
        _story = storyToSave.copyWith(id: id);
        _isSaved = true;
        notifyListeners();
        return true;
      } catch (e) {
        _isSaving = false;
        notifyListeners();
        return false;
      }
    }
    return false;
  }

  Future<void> updateRating(double rating) async {
    if (_story != null && _story!.id != null) {
      await _updateRatingUseCase(_story!.id!, rating);
      _story = _story!.copyWith(rating: rating);
      _rating = rating;
      notifyListeners();
    }
  }

  Future<void> deleteStory() async {
    if (_story != null && _story!.id != null) {
      await _deleteStoryUseCase(_story!.id!);
      _isSaved = false;
      notifyListeners();
    }
  }

  void unsaveStory() {
    _isSaved = false;
    notifyListeners();
  }

  void toggleMemoryExpanded() {
    _isMemoryExpanded = !_isMemoryExpanded;
    notifyListeners();
  }

  Future<void> continueStory({
    required int storyId,
    required String continuationPrompt,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _continueStoryUseCase(
        storyId: storyId,
        continuationPrompt: continuationPrompt,
      );

      // Recargar la historia actualizada y actualizar la historia actual
      _currentStory = await _repository.getStoryById(storyId);
      if (_story?.id == storyId) {
        _story = _currentStory;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStory(int storyId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentStory = await _repository.getStoryById(storyId);
    } catch (e) {
      _error = e.toString();
      _currentStory = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCurrentStory() {
    _currentStory = null;
    _error = null;
    notifyListeners();
  }
}
