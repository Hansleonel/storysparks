import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/home/domain/usecases/get_user_name_usecase.dart';
import 'package:memorysparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';
import 'package:memorysparks/features/story/domain/usecases/generate_story_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/get_image_description_usecase.dart';

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
  final GenerateStoryUseCase _generateStoryUseCase;
  final GetImageDescriptionUseCase _getImageDescriptionUseCase;

  String? _imageDescription;
  String? get imageDescription => _imageDescription;
  bool _isProcessingImage = false;
  bool get isProcessingImage => _isProcessingImage;

  HomeProvider(
    this._getUserNameUseCase,
    this._authRepository,
    this._generateStoryUseCase,
    this._getImageDescriptionUseCase,
  ) {
    debugPrint('🏠 HomeProvider: Inicializando...');
    memoryController.addListener(_updateGenerateButton);
    _loadUserName();
  }

  String? get userName => _userName;

  Future<void> _loadUserName() async {
    debugPrint('🏠 HomeProvider: Cargando nombre de usuario...');
    final result = await _getUserNameUseCase(NoParams());
    result.fold(
      (failure) {
        debugPrint(
            '🏠 HomeProvider: Error al cargar nombre de usuario: $failure');
        _userName = 'Usuario';
      },
      (name) {
        debugPrint(
            '🏠 HomeProvider: Nombre de usuario cargado: ${name ?? 'Usuario'}');
        _userName = name ?? 'Usuario';
      },
    );
    notifyListeners();
  }

  void _updateGenerateButton() {
    final bool newState = memoryController.text.isNotEmpty;
    if (isGenerateEnabled != newState) {
      debugPrint(
          '🏠 HomeProvider: Botón de generar ${newState ? 'habilitado' : 'deshabilitado'}');
      isGenerateEnabled = newState;
      notifyListeners();
    }
  }

  void setSelectedGenre(String genre) {
    debugPrint('🏠 HomeProvider: Género seleccionado: $genre');
    selectedGenre = genre;
    notifyListeners();
  }

  void setSelectedImage(String path) async {
    selectedImagePath = path;
    notifyListeners();

    // Procesar la imagen automáticamente
    await processImage(path);
  }

  void removeSelectedImage() {
    selectedImagePath = null;
    _imageDescription = null;
    notifyListeners();
  }

  void unfocusMemoryInput() {
    debugPrint('🏠 HomeProvider: Input de memoria perdió el foco');
    memoryFocusNode.unfocus();
  }

  void resetState() {
    debugPrint('🏠 HomeProvider: Reseteando estados...');
    memoryController.clear();
    selectedGenre = '';
    selectedImagePath = null;
    _imageDescription = null;
    isGenerateEnabled = false;
    notifyListeners();
  }

  Future<void> processImage(String imagePath) async {
    _isProcessingImage = true;
    notifyListeners();

    final result = await _getImageDescriptionUseCase(imagePath);

    result.fold((failure) {
      debugPrint(
          '❌ HomeProvider: Error al procesar imagen - ${failure.message}');
      _imageDescription = null;
    }, (description) {
      debugPrint('✅ HomeProvider: Imagen procesada exitosamente');
      debugPrint(
          '   Longitud de la descripción: ${description.length} caracteres');
      debugPrint('   Descripción: $description');
      _imageDescription = description;
    });

    _isProcessingImage = false;
    notifyListeners();
  }

  Future<Story> generateStory() async {
    debugPrint('🏠 HomeProvider: Iniciando generación de historia...');
    debugPrint('🏠 HomeProvider: Validando datos...');

    if (memoryController.text.isEmpty) {
      debugPrint('❌ HomeProvider: Error - Recuerdo vacío');
      throw Exception('Por favor, ingresa un recuerdo');
    }

    if (selectedGenre.isEmpty) {
      debugPrint('❌ HomeProvider: Error - Género no seleccionado');
      throw Exception('Por favor, selecciona un género');
    }

    debugPrint('🏠 HomeProvider: Obteniendo usuario actual...');
    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser == null) {
      debugPrint('❌ HomeProvider: Error - Usuario no autenticado');
      throw Exception('Usuario no autenticado');
    }
    debugPrint('🏠 HomeProvider: Usuario autenticado: ${currentUser.id}');

    isLoading = true;
    notifyListeners();

    try {
      debugPrint('🏠 HomeProvider: Llamando a GenerateStoryUseCase...');
      debugPrint('📝 Datos de entrada:');
      debugPrint('   - Memoria: ${memoryController.text}');
      debugPrint('   - Género: $selectedGenre');
      debugPrint('   - Usuario ID: ${currentUser.id}');
      if (_imageDescription != null) {
        debugPrint('   - Descripción de imagen: $_imageDescription');
      }

      final result = await _generateStoryUseCase.execute(
        memory: memoryController.text,
        genre: selectedGenre,
        userId: currentUser.id,
        imageDescription: _imageDescription,
        imagePath: selectedImagePath,
      );

      return result.fold(
        (failure) {
          final errorMessage = failure.message.toLowerCase();
          debugPrint(
              '❌ HomeProvider: Error detallado del servidor: $errorMessage');

          if (errorMessage.contains('overloaded') ||
              errorMessage.contains('try again later')) {
            debugPrint('❌ HomeProvider: Detectada sobrecarga del servidor');
            throw Exception(
                'El servicio está experimentando alta demanda. Por favor, intenta de nuevo en unos minutos.');
          }

          throw Exception(failure.message);
        },
        (story) {
          debugPrint('✅ HomeProvider: Historia generada exitosamente');
          debugPrint('   - ID: ${story.id}');
          debugPrint('   - Título: ${story.title}');
          debugPrint('   - Género: ${story.genre}');
          debugPrint(
              '   - Contenido: ${story.content.substring(0, min(50, story.content.length))}...');
          return story;
        },
      );
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      debugPrint('❌ HomeProvider: Error completo: $e');

      if (errorMessage.contains('overloaded') ||
          errorMessage.contains('try again later')) {
        debugPrint('❌ HomeProvider: Error de sobrecarga detectado');
        throw Exception(
            'El servicio está experimentando alta demanda. Por favor, intenta de nuevo en unos minutos.');
      } else if (e is Exception) {
        throw e;
      } else {
        throw Exception(
            'Ocurrió un error inesperado al generar la historia. Por favor, intenta de nuevo.');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    debugPrint('🏠 HomeProvider: Limpiando recursos...');
    memoryController.dispose();
    memoryFocusNode.dispose();
    super.dispose();
  }
}
