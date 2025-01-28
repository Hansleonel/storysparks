import 'package:flutter/foundation.dart';
import 'package:storysparks/features/story/domain/entities/story.dart';
import 'package:storysparks/features/profile/domain/usecases/get_user_stories_usecase.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';

class StoryProvider extends ChangeNotifier {
  final GetUserStoriesUseCase _getUserStoriesUseCase;
  final AuthRepository _authRepository;
  List<Story> _stories = [];
  bool _isLoading = false;
  String? _error;

  StoryProvider(this._getUserStoriesUseCase, this._authRepository);

  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserStories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      _stories = await _getUserStoriesUseCase(currentUser.id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _stories = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
