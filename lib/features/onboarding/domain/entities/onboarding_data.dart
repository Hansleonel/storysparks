import 'package:equatable/equatable.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';

/// Estado del onboarding que contiene todos los datos recopilados durante el flujo.
class OnboardingData extends Equatable {
  final String userName;
  final String memoryText;
  final String? selectedImagePath;
  final String? imageDescription;
  final Story? generatedStory;
  final int currentStep;
  final bool isCompleted;

  const OnboardingData({
    this.userName = '',
    this.memoryText = '',
    this.selectedImagePath,
    this.imageDescription,
    this.generatedStory,
    this.currentStep = 0,
    this.isCompleted = false,
  });

  OnboardingData copyWith({
    String? userName,
    String? memoryText,
    String? selectedImagePath,
    String? imageDescription,
    Story? generatedStory,
    int? currentStep,
    bool? isCompleted,
  }) {
    return OnboardingData(
      userName: userName ?? this.userName,
      memoryText: memoryText ?? this.memoryText,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      imageDescription: imageDescription ?? this.imageDescription,
      generatedStory: generatedStory ?? this.generatedStory,
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        userName,
        memoryText,
        selectedImagePath,
        imageDescription,
        generatedStory,
        currentStep,
        isCompleted,
      ];
}
