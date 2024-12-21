import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  final TextEditingController memoryController = TextEditingController();
  final FocusNode memoryFocusNode = FocusNode();
  String selectedGenre = '';
  bool isGenerateEnabled = false;

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

  void unfocusMemoryInput() {
    memoryFocusNode.unfocus();
  }

  @override
  void dispose() {
    memoryController.dispose();
    memoryFocusNode.dispose();
    super.dispose();
  }
}