import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/story.dart';
import '../../domain/usecases/delete_story_usecase.dart';
import '../../domain/usecases/update_story_rating_usecase.dart';
import '../../domain/usecases/save_story_usecase.dart';
import '../../domain/usecases/update_story_status_usecase.dart';
import '../../domain/usecases/continue_story_usecase.dart';
import '../../domain/usecases/get_story_by_id_usecase.dart';

class StoryProvider extends ChangeNotifier {
  final UpdateStoryRatingUseCase _updateRatingUseCase;
  final DeleteStoryUseCase _deleteStoryUseCase;
  final SaveStoryUseCase _saveStoryUseCase;
  final UpdateStoryStatusUseCase _updateStoryStatusUseCase;
  final ContinueStoryUseCase _continueStoryUseCase;
  final GetStoryByIdUseCase _getStoryByIdUseCase;

  bool _isExpanded = false;
  bool _isMemoryExpanded = false;
  bool _isAtBottom = false;
  double _rating = 5.0;
  Story? _story;
  bool _isSaving = false;
  bool _isSaved = false;
  bool _isContinuing = false;
  String? _error;
  bool _isCopied = false;

  StoryProvider({
    required UpdateStoryRatingUseCase updateRatingUseCase,
    required DeleteStoryUseCase deleteStoryUseCase,
    required SaveStoryUseCase saveStoryUseCase,
    required UpdateStoryStatusUseCase updateStoryStatusUseCase,
    required ContinueStoryUseCase continueStoryUseCase,
    required GetStoryByIdUseCase getStoryByIdUseCase,
  })  : _updateRatingUseCase = updateRatingUseCase,
        _deleteStoryUseCase = deleteStoryUseCase,
        _saveStoryUseCase = saveStoryUseCase,
        _updateStoryStatusUseCase = updateStoryStatusUseCase,
        _continueStoryUseCase = continueStoryUseCase,
        _getStoryByIdUseCase = getStoryByIdUseCase {
    debugPrint('🔄 StoryProvider: Initializing...');
  }

  bool get isExpanded => _isExpanded;
  bool get isMemoryExpanded => _isMemoryExpanded;
  bool get isAtBottom => _isAtBottom;
  double get rating => _rating;
  Story? get story => _story;
  bool get isSaving => _isSaving;
  bool get isSaved => _isSaved;
  String? get error => _error;
  bool get isContinuing => _isContinuing;
  bool get isCopied => _isCopied;

  void setStory(Story story, {bool isFromLibrary = false}) {
    debugPrint(
        '🔄 StoryProvider: Setting story - ID: ${story.id}, isFromLibrary: $isFromLibrary');
    debugPrint('📊 StoryProvider: Story rating from database: ${story.rating}');

    _story = story;
    _isSaved = isFromLibrary;

    // Si la historia viene de la biblioteca o tiene un rating existente, usamos ese rating
    if (isFromLibrary || story.rating > 0) {
      _rating = story.rating;
      debugPrint('📊 StoryProvider: Using existing rating: $_rating');
    } else {
      // Si es una historia nueva, establecemos el rating inicial a 5.0
      _rating = 5.0;
      debugPrint(
          '📊 StoryProvider: Setting initial rating for new story: $_rating');
    }

    _error = null;
    notifyListeners();
  }

  void toggleExpanded() {
    debugPrint('🔄 StoryProvider: Toggling expanded state');
    _isExpanded = true;
    notifyListeners();
  }

  void setRating(double rating) {
    debugPrint('🔄 StoryProvider: Setting rating: $rating');
    _rating = rating;
    notifyListeners();
  }

  Future<bool> saveStory() async {
    if (_story != null) {
      try {
        debugPrint('🔄 StoryProvider: Starting story save process...');
        _isSaving = true;
        _error = null;
        notifyListeners();

        if (_story!.id != null) {
          // Si la historia ya existe, actualizamos su estado y rating
          debugPrint(
              '📊 StoryProvider: Updating existing story - ID: ${_story!.id}, Rating: $_rating');
          await _updateStoryStatusUseCase(_story!.id!, 'saved');
          await _updateRatingUseCase(_story!.id!, _rating);
          _story = _story!.copyWith(status: 'saved', rating: _rating);
        } else {
          // Si es una nueva historia, la guardamos completa
          final storyToSave = _story!.copyWith(
            rating: 5.0, // Siempre guardamos con 5 estrellas inicialmente
            status: 'saved',
          );
          debugPrint(
              '📊 StoryProvider: Saving new story with rating: ${storyToSave.rating}');
          final id = await _saveStoryUseCase.execute(storyToSave);
          _story = storyToSave.copyWith(id: id);
          _rating = 5.0; // Actualizamos el rating en el provider también
        }

        _isSaved = true;
        _error = null;
        debugPrint('✅ StoryProvider: Save process completed successfully');
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('❌ StoryProvider: Error saving story - $e');
        _error = e.toString();
        _isSaving = false;
        _isSaved = false;
        notifyListeners();
        return false;
      } finally {
        _isSaving = false;
        notifyListeners();
      }
    }
    debugPrint('⚠️ StoryProvider: Cannot save - No story available');
    return false;
  }

  Future<void> updateRating(double rating) async {
    if (_story != null && _story!.id != null) {
      try {
        debugPrint('🔄 StoryProvider: Updating rating to: $rating');
        await _updateRatingUseCase(_story!.id!, rating);
        _story = _story!.copyWith(rating: rating);
        _rating = rating;
        _error = null;
        debugPrint('✅ StoryProvider: Rating updated successfully');
        notifyListeners();
      } catch (e) {
        debugPrint('❌ StoryProvider: Error updating rating - $e');
        _error = e.toString();
        notifyListeners();
      }
    } else {
      debugPrint(
          '⚠️ StoryProvider: Cannot update rating - No story or story ID');
    }
  }

  Future<void> deleteStory() async {
    if (_story != null && _story!.id != null) {
      try {
        debugPrint('🔄 StoryProvider: Deleting story with ID: ${_story!.id}');
        await _updateStoryStatusUseCase(_story!.id!, 'deleted');
        _isSaved = false;
        _error = null;
        debugPrint('✅ StoryProvider: Story marked as deleted successfully');
        notifyListeners();
      } catch (e) {
        debugPrint('❌ StoryProvider: Error deleting story - $e');
        _error = e.toString();
        notifyListeners();
      }
    } else {
      debugPrint('⚠️ StoryProvider: Cannot delete - No story or story ID');
    }
  }

  Future<void> hardDeleteStory() async {
    if (_story != null && _story!.id != null) {
      try {
        debugPrint(
            '🔄 StoryProvider: Hard deleting story with ID: ${_story!.id}');
        await _deleteStoryUseCase(_story!.id!);
        _story = null;
        _isSaved = false;
        _error = null;
        debugPrint('✅ StoryProvider: Story deleted successfully');
        notifyListeners();
      } catch (e) {
        debugPrint('❌ StoryProvider: Error deleting story - $e');
        _error = e.toString();
        notifyListeners();
      }
    } else {
      debugPrint('⚠️ StoryProvider: Cannot delete - No story or story ID');
    }
  }

  void unsaveStory() {
    debugPrint('🔄 StoryProvider: Unsaving story');
    _isSaved = false;
    notifyListeners();
  }

  void toggleMemoryExpanded() {
    debugPrint('🔄 StoryProvider: Toggling memory expanded state');
    _isMemoryExpanded = !_isMemoryExpanded;
    notifyListeners();
  }

  void updateScrollPosition(double maxScroll, double currentScroll) {
    final delta = 50.0; // margen de error para considerar que está al final
    final shouldBeAtBottom = (maxScroll - currentScroll) <= delta;

    if (_isAtBottom != shouldBeAtBottom) {
      debugPrint('🔄 StoryProvider: Scroll position updated');
      debugPrint('📏 MaxScroll: $maxScroll, CurrentScroll: $currentScroll');
      debugPrint('📍 Is at bottom: $shouldBeAtBottom');
      _isAtBottom = shouldBeAtBottom;
      notifyListeners();
    }
  }

  Future<bool> continueStory() async {
    if (_story != null && _story!.id != null) {
      try {
        debugPrint('🔄 StoryProvider: Starting story continuation process...');
        debugPrint(
            '📊 StoryProvider: Before continuation - Story ID: ${_story!.id}');
        debugPrint(
            '🔢 StoryProvider: Before continuation - Continuation Count: ${_story!.continuationCount}');

        _isContinuing = true;
        _error = null;
        notifyListeners();

        final result = await _continueStoryUseCase.execute(_story!);

        return result.fold(
          (failure) {
            debugPrint('❌ StoryProvider: Error continuing story - $failure');
            _error = failure.toString();
            notifyListeners();
            return false;
          },
          (updatedStory) async {
            debugPrint(
                '📊 StoryProvider: After continuation - Story ID: ${updatedStory.id}');
            debugPrint(
                '🔢 StoryProvider: After continuation - Continuation Count: ${updatedStory.continuationCount}');

            _story = updatedStory;
            _error = null;
            debugPrint(
                '✅ StoryProvider: Story continuation completed successfully');

            // El contador de continuaciones ya se incrementa en el repositorio
            // No es necesario llamar al caso de uso aquí

            notifyListeners();
            return true;
          },
        );
      } finally {
        _isContinuing = false;
        notifyListeners();
      }
    }
    debugPrint(
        '⚠️ StoryProvider: Cannot continue - No story or story ID available');
    return false;
  }

  Future<void> copyStoryToClipboard() async {
    try {
      if (_story != null) {
        await Clipboard.setData(ClipboardData(text: _story!.content));
        _isCopied = true;
        notifyListeners();

        // Reset copied state after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        _isCopied = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error copying to clipboard: $e');
      _error = 'Error al copiar la historia';
      notifyListeners();
    }
  }

  Future<void> reloadStoryFromDatabase() async {
    if (_story != null && _story!.id != null) {
      try {
        debugPrint(
            '🔄 StoryProvider: Recargando historia desde la base de datos');
        debugPrint('📊 StoryProvider: ID de historia: ${_story!.id}');

        final updatedStory = await _getStoryByIdUseCase.execute(_story!.id!);

        if (updatedStory != null) {
          debugPrint('✅ StoryProvider: Historia recargada exitosamente');
          debugPrint(
              '🔢 StoryProvider: Contador de continuaciones actualizado: ${updatedStory.continuationCount}');

          _story = updatedStory;
          _rating = updatedStory.rating;
          notifyListeners();
        } else {
          debugPrint(
              '⚠️ StoryProvider: No se pudo encontrar la historia en la base de datos');
        }
      } catch (e) {
        debugPrint('❌ StoryProvider: Error recargando historia - $e');
        _error = e.toString();
      }
    } else {
      debugPrint(
          '⚠️ StoryProvider: No se puede recargar - No hay historia o ID');
    }
  }
}
