import 'package:flutter/material.dart';
import 'package:storysparks/core/dependency_injection/service_locator.dart';
import 'package:storysparks/core/usecases/usecase.dart';
import 'package:storysparks/features/story/data/datasources/story_local_datasource.dart';
import 'package:storysparks/features/home/domain/usecases/get_user_name_usecase.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';
import '../../../story/domain/entities/story.dart';
import '../../../story/data/repositories/story_repository_impl.dart';

class HomeProvider extends ChangeNotifier {
  final TextEditingController memoryController = TextEditingController();
  final FocusNode memoryFocusNode = FocusNode();
  String selectedGenre = '';
  bool isGenerateEnabled = false;
  String? selectedImagePath;
  bool isLoading = false;
  String? _userName;
  final GetUserNameUseCase _getUserNameUseCase;
  final AuthRepository _authRepository;

  final _storyRepository = StoryRepositoryImpl(getIt<StoryLocalDatasource>());

  HomeProvider(this._getUserNameUseCase, this._authRepository) {
    memoryController.addListener(_updateGenerateButton);
    _loadUserName();
  }

  String? get userName => _userName;

  Future<void> _loadUserName() async {
    final result = await _getUserNameUseCase(NoParams());
    result.fold(
      (failure) => _userName = 'Usuario',
      (name) => _userName = name ?? 'Usuario',
    );
    notifyListeners();
  }

  void _updateGenerateButton() {
    final bool newState = memoryController.text.isNotEmpty;
    if (isGenerateEnabled != newState) {
      isGenerateEnabled = newState;
      notifyListeners();
    }
  }

  void setSelectedGenre(String genre) {
    selectedGenre = genre;
    notifyListeners();
  }

  void setSelectedImage(String path) {
    selectedImagePath = path;
    notifyListeners();
  }

  void removeSelectedImage() {
    selectedImagePath = null;
    notifyListeners();
  }

  void unfocusMemoryInput() {
    memoryFocusNode.unfocus();
  }

  Future<Story> generateStory() async {
    if (memoryController.text.isEmpty) {
      throw Exception('Por favor, ingresa un recuerdo');
    }

    if (selectedGenre.isEmpty) {
      throw Exception('Por favor, selecciona un género');
    }

    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    isLoading = true;
    notifyListeners();

    try {
      final story = await _storyRepository.generateStory(
        memory: memoryController.text,
        genre: selectedGenre,
        userId: currentUser.id,
      );
      return story;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    memoryController.dispose();
    memoryFocusNode.dispose();
    super.dispose();
  }
}
