import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:memorysparks/features/onboarding/domain/usecases/check_first_time_user_usecase.dart';
import 'package:memorysparks/features/onboarding/domain/usecases/mark_onboarding_complete_usecase.dart';
import 'package:memorysparks/features/onboarding/domain/usecases/transfer_story_to_user_usecase.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';
import 'package:memorysparks/features/story/domain/entities/story_params.dart';
import 'package:memorysparks/features/story/domain/usecases/generate_story_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/get_image_description_usecase.dart';

/// Provider que maneja el estado del onboarding.
class OnboardingProvider extends ChangeNotifier {
  final CheckFirstTimeUserUseCase _checkFirstTimeUserUseCase;
  final MarkOnboardingCompleteUseCase _markOnboardingCompleteUseCase;
  final TransferStoryToUserUseCase _transferStoryToUserUseCase;
  final GenerateStoryUseCase _generateStoryUseCase;
  final GetImageDescriptionUseCase _getImageDescriptionUseCase;

  OnboardingProvider({
    required CheckFirstTimeUserUseCase checkFirstTimeUserUseCase,
    required MarkOnboardingCompleteUseCase markOnboardingCompleteUseCase,
    required TransferStoryToUserUseCase transferStoryToUserUseCase,
    required GenerateStoryUseCase generateStoryUseCase,
    required GetImageDescriptionUseCase getImageDescriptionUseCase,
  })  : _checkFirstTimeUserUseCase = checkFirstTimeUserUseCase,
        _markOnboardingCompleteUseCase = markOnboardingCompleteUseCase,
        _transferStoryToUserUseCase = transferStoryToUserUseCase,
        _generateStoryUseCase = generateStoryUseCase,
        _getImageDescriptionUseCase = getImageDescriptionUseCase;

  // ============================================
  // STATE
  // ============================================

  OnboardingData _data = const OnboardingData();
  OnboardingData get data => _data;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isGeneratingStory = false;
  bool get isGeneratingStory => _isGeneratingStory;

  bool _isProcessingImage = false;
  bool get isProcessingImage => _isProcessingImage;

  String? _error;
  String? get error => _error;

  String? _imageDescription;
  String? get imageDescription => _imageDescription;

  // ============================================
  // PRESET MEMORIES
  // ============================================

  static const List<String> presetMemories = [
    // Recuerdo 1
    "La conocí por casualidad, ella parada en una esquina del colegio, yo esperando a un amigo que había olvidado su mochila. Mi duda al verla de tan lejos era: ¿si era tan linda de lejos también lo era de cerca? Quizás me confunde la distancia o quizás solo es la ansiedad de verla esa primera vez.",

    // Recuerdo 2
    "La primera vez que me sonrió fue en la fila de la cafetería. Yo fingía buscar algo en mi mochila mientras ella pedía un café. ¿Me habría visto? ¿Sabría que mi corazón latía tan fuerte que podían escucharlo en la otra mesa? Ese día aprendí que una sonrisa puede cambiar el rumbo de un martes cualquiera.",

    // Recuerdo 3
    "La tarde que me prestó su paraguas aunque ella también lo necesitaba. Llovía como si el cielo quisiera borrar la ciudad entera. Ella corrió hacia mí, me lo puso en las manos y desapareció entre la lluvia antes de que pudiera decir gracias. Nunca supe si fue amabilidad o si ella también sentía algo más.",

    // Recuerdo 4
    "El mensaje de las 3am que decía solo 'no puedo dormir'. Tres palabras, ninguna explicación, todo un universo de posibilidades. ¿Pensaba en mí? ¿O solo era yo el único despierto para responder? Tardé 42 minutos en contestar para no parecer desesperado. Ella respondió en 3 segundos.",
  ];

  // ============================================
  // METHODS
  // ============================================

  /// Verifica si es la primera vez que el usuario abre la app.
  Future<bool> isFirstTimeUser() async {
    final result = await _checkFirstTimeUserUseCase(NoParams());
    return result.fold(
      (failure) {
        debugPrint('❌ OnboardingProvider: ${failure.message}');
        return true; // Default a true si hay error
      },
      (isFirstTime) => isFirstTime,
    );
  }

  /// Establece el nombre del usuario.
  void setUserName(String name) {
    _data = _data.copyWith(userName: name);
    notifyListeners();
  }

  /// Establece el texto del recuerdo.
  void setMemoryText(String text) {
    _data = _data.copyWith(memoryText: text);
    notifyListeners();
  }

  /// Selecciona un recuerdo aleatorio de los preset.
  /// Si se proveen memories localizados, los usa; sino usa los defaults.
  String getRandomMemory([List<String>? localizedMemories]) {
    final random = Random();
    final memories = localizedMemories ?? presetMemories;
    final memory = memories[random.nextInt(memories.length)];
    _data = _data.copyWith(memoryText: memory);
    notifyListeners();
    return memory;
  }

  /// Establece la imagen seleccionada y procesa su descripción.
  Future<void> setSelectedImage(String path) async {
    _data = _data.copyWith(selectedImagePath: path);
    notifyListeners();

    // Procesar imagen automáticamente
    await _processImage(path);
  }

  /// Remueve la imagen seleccionada.
  void removeSelectedImage() {
    _data = OnboardingData(
      userName: _data.userName,
      memoryText: _data.memoryText,
      currentStep: _data.currentStep,
      isCompleted: _data.isCompleted,
      generatedStory: _data.generatedStory,
    );
    _imageDescription = null;
    notifyListeners();
  }

  /// Procesa la imagen para obtener su descripción.
  Future<void> _processImage(String imagePath) async {
    _isProcessingImage = true;
    notifyListeners();

    final result = await _getImageDescriptionUseCase(imagePath);

    result.fold(
      (failure) {
        debugPrint(
            '❌ OnboardingProvider: Error procesando imagen: ${failure.message}');
        _imageDescription = null;
      },
      (description) {
        debugPrint('✅ OnboardingProvider: Imagen procesada');
        _imageDescription = description;
        _data = _data.copyWith(imageDescription: description);
      },
    );

    _isProcessingImage = false;
    notifyListeners();
  }

  /// Genera la historia de preview.
  Future<Story?> generatePreviewStory() async {
    if (_data.memoryText.isEmpty) {
      _error = 'Por favor, ingresa un recuerdo';
      notifyListeners();
      return null;
    }

    _isGeneratingStory = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🎯 OnboardingProvider: Generando historia de preview...');

      final result = await _generateStoryUseCase.execute(
        params: StoryParams(
          memoryText: _data.memoryText,
          genre: 'romantic', // Default genre para onboarding
          imageDescription: _imageDescription,
          imagePath: _data.selectedImagePath,
        ),
        userId: 'onboarding_preview', // ID temporal
      );

      return result.fold(
        (failure) {
          debugPrint('❌ OnboardingProvider: ${failure.message}');
          _error = failure.message;
          _isGeneratingStory = false;
          notifyListeners();
          return null;
        },
        (story) {
          debugPrint(
              '✅ OnboardingProvider: Historia generada - ${story.title}');
          _data = _data.copyWith(generatedStory: story);
          _isGeneratingStory = false;
          notifyListeners();
          return story;
        },
      );
    } catch (e) {
      debugPrint('❌ OnboardingProvider: Error inesperado: $e');
      _error = 'Error al generar la historia';
      _isGeneratingStory = false;
      notifyListeners();
      return null;
    }
  }

  /// Transfiere la historia al usuario después del registro.
  Future<Story?> transferStoryToUser(String userId) async {
    if (_data.generatedStory == null) {
      debugPrint('⚠️ OnboardingProvider: No hay historia para transferir');
      return null;
    }

    _isLoading = true;
    notifyListeners();

    final result = await _transferStoryToUserUseCase(
      TransferStoryParams(
        story: _data.generatedStory!,
        userId: userId,
      ),
    );

    _isLoading = false;

    return result.fold(
      (failure) {
        debugPrint('❌ OnboardingProvider: ${failure.message}');
        _error = failure.message;
        notifyListeners();
        return null;
      },
      (story) {
        debugPrint('✅ OnboardingProvider: Historia transferida al usuario');
        notifyListeners();
        return story;
      },
    );
  }

  /// Marca el onboarding como completado.
  Future<void> completeOnboarding() async {
    final result = await _markOnboardingCompleteUseCase(NoParams());
    result.fold(
      (failure) => debugPrint('❌ OnboardingProvider: ${failure.message}'),
      (_) => debugPrint('✅ OnboardingProvider: Onboarding completado'),
    );
    _data = _data.copyWith(isCompleted: true);
    notifyListeners();
  }

  /// Avanza al siguiente paso del onboarding.
  void nextStep() {
    _data = _data.copyWith(currentStep: _data.currentStep + 1);
    notifyListeners();
  }

  /// Retrocede al paso anterior.
  void previousStep() {
    if (_data.currentStep > 0) {
      _data = _data.copyWith(currentStep: _data.currentStep - 1);
      notifyListeners();
    }
  }

  /// Limpia los errores.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Resetea todo el estado del onboarding.
  void reset() {
    _data = const OnboardingData();
    _isLoading = false;
    _isGeneratingStory = false;
    _isProcessingImage = false;
    _error = null;
    _imageDescription = null;
    notifyListeners();
  }
}
