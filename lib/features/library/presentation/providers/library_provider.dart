import 'package:flutter/material.dart';
import 'package:memorysparks/features/story/data/datasources/story_local_datasource.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';
import 'package:memorysparks/features/auth/domain/repositories/auth_repository.dart';

enum LibraryViewType {
  grid, // Vista actual con scroll horizontal
  timeline // Nueva vista vertical tipo timeline
}

class LibraryProvider extends ChangeNotifier {
  final _localDatasource = StoryLocalDatasource();
  final AuthRepository _authRepository;
  List<Story> _popularStories = [];
  List<Story> _recentStories = [];
  bool _isLoading = false;
  LibraryViewType _viewType = LibraryViewType.timeline;

  LibraryProvider(this._authRepository);

  List<Story> get popularStories => _popularStories;
  List<Story> get recentStories => _recentStories;
  bool get isLoading => _isLoading;
  LibraryViewType get viewType => _viewType;

  void toggleViewType() {
    _viewType = _viewType == LibraryViewType.grid
        ? LibraryViewType.timeline
        : LibraryViewType.grid;
    notifyListeners();
  }

  Future<void> loadStories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      _popularStories =
          await _localDatasource.getPopularStories(currentUser.id);
      _recentStories = await _localDatasource.getRecentStories(currentUser.id);

      // Aseguramos que las historias recientes estén ordenadas por fecha de creación (más recientes primero)
      _recentStories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading stories: $e');
      _popularStories = [];
      _recentStories = [];
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
