import 'package:flutter/material.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/story.dart';
import '../../domain/usecases/delete_story_usecase.dart';
import '../../domain/usecases/update_story_rating_usecase.dart';
import '../../domain/repositories/story_repository.dart';
import '../../domain/usecases/continue_story_usecase.dart';

class StoryProvider extends ChangeNotifier {
  final UpdateStoryRatingUseCase _updateRatingUseCase;
  final DeleteStoryUseCase _deleteStoryUseCase;
  final StoryRepository _repository;
  final ContinueStoryUseCase _continueStoryUseCase;
  final AuthRepository _authRepository;
  final VoidCallback? onStoryStateChanged;

  bool _isExpanded = false;
  bool _isMemoryExpanded = false;
  double _rating = 4.0;
  Story? _story;
  bool _isSaving = false;
  bool _isSaved = false;
  bool _isContinuing = false;
  String? _continuedContent;
  String? _previousContent;

  StoryProvider({
    required UpdateStoryRatingUseCase updateRatingUseCase,
    required DeleteStoryUseCase deleteStoryUseCase,
    required StoryRepository repository,
    required ContinueStoryUseCase continueStoryUseCase,
    required AuthRepository authRepository,
    this.onStoryStateChanged,
  })  : _updateRatingUseCase = updateRatingUseCase,
        _deleteStoryUseCase = deleteStoryUseCase,
        _repository = repository,
        _continueStoryUseCase = continueStoryUseCase,
        _authRepository = authRepository;

  bool get isExpanded => _isExpanded;
  bool get isMemoryExpanded => _isMemoryExpanded;
  double get rating => _rating;
  Story? get story => _story;
  bool get isSaving => _isSaving;
  bool get isSaved => _isSaved;
  bool get isContinuing => _isContinuing;
  String? get continuedContent {
    if (_continuedContent == null) return null;
    if (_previousContent == null) return _continuedContent;
    return '$_previousContent\n\n$_continuedContent';
  }

  bool get hasContinuation => _continuedContent != null;

  void setStory(Story story, {bool isFromLibrary = false}) {
    _saveInitialStory(story, isFromLibrary);
  }

  Future<void> _saveInitialStory(Story story, bool isFromLibrary) async {
    try {
      if (!isFromLibrary) {
        final id = await _repository.saveStory(story);
        _story = story.copyWith(id: id);
        _isSaved = false;
      } else {
        _story = story;
        _isSaved = true;
        _rating = story.rating;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al guardar historia inicial: $e');
    }
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
        final updatedStory = _story!.copyWith(
          isVisible: true,
          rating: _rating,
        );
        await _repository.updateStory(updatedStory);
        _story = updatedStory;
        _isSaved = true;
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('❌ Error al guardar la historia: $e');
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

  Future<void> continueStory() async {
    if (_story == null) return;

    debugPrint('🔄 Iniciando proceso de continuación de historia...');
    debugPrint('📝 Estado actual:');
    debugPrint('- Historia guardada: ${_isSaved}');
    debugPrint('- ID: ${_story?.id}');
    debugPrint(
        '- Contenido previo: ${_previousContent?.length ?? 0} caracteres');
    debugPrint(
        '- Continuación actual: ${_continuedContent?.length ?? 0} caracteres');

    if (_isContinuing) {
      debugPrint('⚠️ Ya hay una continuación en proceso');
      return;
    }

    _isContinuing = true;
    notifyListeners();

    try {
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        _isContinuing = false;
        notifyListeners();
        throw Exception('Usuario no autenticado');
      }

      final currentContent = _previousContent ?? _story!.content;
      if (_continuedContent != null) {
        _previousContent = '$currentContent\n\n$_continuedContent';
      }

      final params = ContinueStoryParams(
        previousStory:
            _story!.copyWith(content: _previousContent ?? _story!.content),
        userId: currentUser.id,
      );

      final continuedStory = await _continueStoryUseCase(params);
      _continuedContent = continuedStory.content;
      debugPrint('📝 Contenido actualizado:');
      debugPrint('- Previo: ${_previousContent?.length ?? 0} caracteres');
      debugPrint(
          '- Continuación: ${_continuedContent?.length ?? 0} caracteres');
      debugPrint('- Total: ${continuedContent?.length ?? 0} caracteres');

      if (_isSaved && _story?.id != null) {
        debugPrint(
            '📝 Historia guardada previamente, actualizando contenido...');
        final baseContent = _previousContent ?? _story!.content;
        final fullContent = '$baseContent\n\n${_continuedContent}';
        debugPrint('📏 Nueva longitud total: ${fullContent.length} caracteres');
        final updatedStory = _story!.copyWith(content: fullContent);

        try {
          await _repository.updateStory(updatedStory);
          _story = updatedStory;
          _continuedContent = null;
          _previousContent = null;
          if (onStoryStateChanged != null) {
            onStoryStateChanged!();
          }
          debugPrint('✅ Historia actualizada exitosamente');
        } catch (e) {
          debugPrint('❌ Error al actualizar la historia: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al continuar la historia: $e');
      _isContinuing = false;
      notifyListeners();
      rethrow;
    } finally {
      _isContinuing = false;
      notifyListeners();
      debugPrint('🔄 Estado de continuación finalizado');
    }
  }
}
