import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum para representar los objetivos de manera independiente del idioma
enum GoalType {
  transformMemories, // Transformar recuerdos en historias mágicas
  createStories, // Crear historias únicas con IA
  improveWriting, // Mejorar mi escritura creativa
  exploreIdeas, // Explorar nuevas ideas narrativas
  other, // Otro objetivo
}

class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;
  GoalType? _selectedGoalType;
  String _painPoint = '';
  bool _hasCompletedOnboarding = false;

  int get currentPage => _currentPage;
  GoalType? get selectedGoalType => _selectedGoalType;
  String get painPoint => _painPoint;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  // Lista de tipos de objetivos disponibles
  List<GoalType> get availableGoalTypes => [
        GoalType.transformMemories,
        GoalType.createStories,
        GoalType.improveWriting,
        GoalType.exploreIdeas,
        GoalType.other,
      ];

  // Inicializar el estado desde SharedPreferences
  Future<void> initializeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompleted = prefs.getBool('hasCompletedOnboarding') ?? false;
    if (hasCompleted) {
      _hasCompletedOnboarding = hasCompleted;
      notifyListeners();
    }
  }

  // Set the completed onboarding status directly
  void setCompletedOnboarding(bool completed) {
    _hasCompletedOnboarding = completed;
    notifyListeners();
  }

  // Set the current page directly
  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  // Reset the current page to 0
  void resetCurrentPage() {
    _currentPage = 0;
    notifyListeners();
  }

  // Navigate to next page
  void nextPage() {
    _currentPage++;
    notifyListeners();
  }

  // Navigate to previous page
  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  // Set the selected goal type
  void setGoalType(GoalType goalType) {
    _selectedGoalType = goalType;
    notifyListeners();
  }

  // Set the pain point
  void setPainPoint(String painPoint) {
    _painPoint = painPoint;
    notifyListeners();
  }

  // Complete onboarding
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);

    // Save user preferences
    if (_selectedGoalType != null) {
      await prefs.setString('userGoalType', _selectedGoalType.toString());
    }

    if (_painPoint.isNotEmpty) {
      await prefs.setString('userPainPoint', _painPoint);
    }

    notifyListeners();
  }

  // Check if user has completed onboarding
  Future<bool> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
    notifyListeners();
    return _hasCompletedOnboarding;
  }

  // Reset onboarding (for testing)
  Future<void> resetOnboarding() async {
    _currentPage = 0;
    _selectedGoalType = null;
    _painPoint = '';
    _hasCompletedOnboarding = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', false);
    notifyListeners();
  }
}
