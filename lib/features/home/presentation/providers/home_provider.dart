import 'package:flutter/material.dart';
import '../../../story/domain/entities/story.dart';
import '../../../story/data/repositories/story_repository_impl.dart';

class HomeProvider extends ChangeNotifier {
  final TextEditingController memoryController = TextEditingController();
  final FocusNode memoryFocusNode = FocusNode();
  String selectedGenre = '';
  bool isGenerateEnabled = false;
  String? selectedImagePath;
  bool isLoading = false;

  final _storyRepository = StoryRepositoryImpl();

  HomeProvider() {
    memoryController.addListener(_updateGenerateButton);
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

    isLoading = true;
    notifyListeners();

    try {
      final story = await _storyRepository.generateStory(
        memory: memoryController.text,
        genre: selectedGenre,
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
