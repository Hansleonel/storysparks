import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:memorysparks/core/utils/cover_image_helper.dart';
import 'dart:io';
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_params.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/story_local_datasource.dart';
import '../managers/chat_session_manager.dart';
import '../services/image_service.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryLocalDatasource _localDatasource;
  final GenerativeModel _model;
  final ImageService _imageService;
  // TODO this line is used to create the session manager, need to check if it's working
  late final ChatSessionManager _sessionManager;

  StoryRepositoryImpl(
    this._localDatasource,
    this._imageService,
  ) : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
        ) {
    // TODO this line is used to create the session manager, need to check if it's working
    _sessionManager = ChatSessionManager(_model);
    debugPrint('🗄️ StoryRepository: Inicializado con modelo gemini-2.0-flash');
  }

  @override
  Future<Story> generateStory({
    required StoryParams params,
    required String userId,
  }) async {
    debugPrint('🗄️ StoryRepository: Iniciando generación de historia');
    debugPrint(
        '   - Idioma solicitado: ${params.targetLanguage ?? 'No especificado (usará español por defecto)'}');

    String? processedImagePath;

    if (params.imagePath != null && params.imagePath!.isNotEmpty) {
      processedImagePath =
          await _imageService.processAndSaveStoryImage(params.imagePath!);
      if (processedImagePath == null) {
        debugPrint(
            '⚠️ StoryRepository: No se pudo procesar la imagen, se usará la imagen por defecto');
      }
    }

    try {
      debugPrint('🗄️ StoryRepository: Preparando prompt con:');
      debugPrint(
          '   - Memoria (longitud): ${params.memoryText.length} caracteres');
      debugPrint('   - Género solicitado: ${params.genre}');
      debugPrint('   - ID de usuario: $userId');

      if (params.imageDescription != null) {
        debugPrint('📸 StoryRepository: Descripción de imagen disponible:');
        debugPrint(params.imageDescription!);
      }

      final languageName = _getLanguageName(params.targetLanguage);

      final prompt = '''
Genera una historia cautivadora inspirada en el siguiente recuerdo personal: "${params.memoryText}".${params.imageDescription != null ? '\nTeniendo en cuenta esta descripción de la imagen relacionada: "${params.imageDescription}".' : ''}
El género de la historia será ${params.genre}. Por favor, genera la historia en $languageName
Instrucciones específicas:

Comienza con una frase breve y poderosa que despierte el interés, ya sea presentando un detalle sensorial, una pregunta intrigante o situando la acción.
A lo largo del relato, mantén un tono emotivo y describe escenas con detalles vívidos, conservando la esencia del recuerdo original.
Evita comenzar siempre de la misma forma; varía entre descripciones sensoriales, preguntas directas, diálogos o metáforas.
Asegura que la historia se mantenga coherente con el género (${params.genre}), sin perder el matiz personal del recuerdo.
Para cerrar, ofrece un desenlace abierto para que el usuario pueda continuar la historia, recuerda generar la historia en el idioma $languageName, recuerda empezar directamente con la historia, no con una respuesta como aqui esta la historia, o cosas que no sean parte de la historia.
''';

      debugPrint('🤖 StoryRepository: Enviando prompt a Gemini...');
      debugPrint('   Longitud del prompt: ${prompt.length} caracteres');

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        debugPrint('❌ StoryRepository: Gemini no generó contenido');
        throw Exception('No se pudo generar la historia');
      }

      debugPrint('✅ StoryRepository: Respuesta recibida de Gemini');
      debugPrint(
          '   Longitud de la respuesta: ${response.text!.length} caracteres');

      final story = Story(
        content: response.text!,
        genre: params.genre,
        createdAt: DateTime.now(),
        memory: params.memoryText,
        userId: userId,
        title: 'Mi Historia de ${params.genre.toLowerCase()}',
        imageUrl: CoverImageHelper.getCoverImage(params.genre),
        customImagePath: processedImagePath,
        status: 'draft',
      );

      debugPrint('✅ StoryRepository: Historia creada exitosamente');
      debugPrint('   - Título: ${story.title}');
      debugPrint('   - Fecha: ${story.createdAt}');
      debugPrint('   - URL de imagen: ${story.imageUrl}');
      if (processedImagePath != null) {
        debugPrint('   - Imagen personalizada: $processedImagePath');
      }

      final id = await _localDatasource.saveStory(story);
      debugPrint('✅ StoryRepository: Historia guardada como draft con ID: $id');
      return story.copyWith(id: id);
    } catch (e) {
      if (processedImagePath != null) {
        await _imageService.deleteStoryImage(processedImagePath);
      }
      debugPrint('❌ StoryRepository: Error durante la generación');
      debugPrint('   Error detallado: $e');
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<Story> continueStory(Story story) async {
    debugPrint('🗄️ StoryRepository: Iniciando continuación de historia');

    if (story.id == null) {
      throw Exception('No se puede continuar una historia sin ID');
    }

    try {
      final chatSession =
          _sessionManager.getOrCreateSession(story.id.toString(), story);

      const prompt =
          'Continúa la narración de forma natural y coherente. La continuación debe mantener el mismo tono y estilo y dale un desenlace abierto para que el usuario pueda continuar la historia.';

      debugPrint('🤖 StoryRepository: Solicitando continuación...');
      final response = await chatSession.sendMessage(Content.text(prompt));

      if (response.text == null) {
        throw Exception('No se pudo continuar la historia');
      }

      debugPrint('✅ StoryRepository: Continuación generada exitosamente');

      // Crear una versión actualizada de la historia con la continuación
      final updatedStory = story.copyWith(
        content: '${story.content}\n\n--- Continuación ---\n\n${response.text}',
        rating: story.rating > 0
            ? story.rating
            : 5.0, // Mantener el rating existente o usar 5.0 si es 0
      );

      // Actualizar la historia existente en la base de datos
      await _localDatasource.updateStoryContent(updatedStory);
      debugPrint('✅ StoryRepository: Historia actualizada en base de datos');

      return updatedStory;
    } catch (e) {
      debugPrint('❌ StoryRepository: Error durante la continuación');
      debugPrint('   Error detallado: $e');

      if (story.id != null) {
        _sessionManager.clearSession(story.id.toString());
      }

      _handleError(e);
      rethrow;
    }
  }

  void _handleError(dynamic e) {
    final errorMessage = e.toString().toLowerCase();

    if (errorMessage.contains('429') ||
        errorMessage.contains('too many requests')) {
      throw Exception(
          'Has excedido el límite de solicitudes. Por favor, espera unos minutos.');
    }

    if (errorMessage.contains('model is overloaded')) {
      throw Exception(
          'El servicio está temporalmente sobrecargado. Por favor, intenta de nuevo.');
    }
  }

  @override
  Future<int> saveStory(Story story) async {
    return await _localDatasource.saveStory(story);
  }

  @override
  Future<void> updateStoryStatus(int storyId, String status) async {
    await _localDatasource.updateStoryStatus(storyId, status);
  }

  @override
  Future<List<Story>> getSavedStories(String userId) async {
    return await _localDatasource.getSavedStories(userId);
  }

  @override
  Future<void> updateRating(int storyId, double rating) async {
    await _localDatasource.updateRating(storyId, rating);
  }

  @override
  Future<void> deleteStory(int storyId) async {
    final story = await _localDatasource.getStoryById(storyId);
    if (story != null && story.customImagePath != null) {
      await _imageService.deleteStoryImage(story.customImagePath);
    }
    await _localDatasource.deleteStory(storyId);
  }

  @override
  Future<void> incrementReadCount(int storyId) async {
    await _localDatasource.incrementReadCount(storyId);
  }

  @override
  Future<List<Story>> getPopularStories(String userId) async {
    return await _localDatasource.getPopularStories(userId);
  }

  @override
  Future<List<Story>> getRecentStories(String userId) async {
    return await _localDatasource.getRecentStories(userId);
  }

  @override
  Future<void> cleanupOldDraftStories() async {
    await _localDatasource.cleanupOldDraftStories();
  }

  @override
  Future<String> getImageDescription(String imagePath) async {
    debugPrint('🖼️ StoryRepository: Iniciando análisis de imagen');
    debugPrint('   Ruta de la imagen: $imagePath');

    try {
      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        debugPrint('❌ StoryRepository: Archivo de imagen no encontrado');
        throw Exception('file not found');
      }

      final int fileSize = await imageFile.length();
      if (fileSize > 20 * 1024 * 1024) {
        // 20MB en bytes
        debugPrint(
            '❌ StoryRepository: Imagen demasiado grande (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB)');
        throw Exception('too large');
      }

      final List<int> imageBytes = await imageFile.readAsBytes();
      final String mimeType = lookupMimeType(imagePath) ?? 'image/jpeg';

      if (!['image/jpeg', 'image/png', 'image/webp', 'image/heic']
          .contains(mimeType)) {
        debugPrint(
            '❌ StoryRepository: Formato de imagen no soportado ($mimeType)');
        throw Exception('invalid format');
      }

      debugPrint('🤖 StoryRepository: Enviando imagen a Gemini para análisis');
      debugPrint('   Tipo MIME: $mimeType');
      debugPrint('   Tamaño: ${(fileSize / 1024).toStringAsFixed(2)}KB');

      final prompt = '''
Analiza esta imagen y proporciona una descripción detallada enfocándote en:
1. Las emociones y el ambiente que transmite
2. Los elementos principales y su significado
3. Los detalles que podrían ser relevantes para una historia
4. El contexto temporal y espacial si es evidente

Mantén la descripción concisa pero rica en detalles significativos.
''';

      final dio = Dio();
      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
        queryParameters: {
          'key': dotenv.env['GEMINI_API_KEY'],
        },
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': mimeType,
                    'data': base64.encode(imageBytes)
                  }
                }
              ]
            }
          ]
        },
      );

      if (response.statusCode != 200) {
        debugPrint('❌ StoryRepository: Error en la respuesta de Gemini');
        debugPrint('   Código: ${response.statusCode}');
        debugPrint('   Respuesta: ${response.data}');
        throw Exception('Error en la respuesta de Gemini');
      }

      final text =
          response.data['candidates'][0]['content']['parts'][0]['text'];
      if (text == null) {
        debugPrint('❌ StoryRepository: Gemini no generó descripción');
        throw Exception('No se pudo generar la descripción de la imagen');
      }

      debugPrint(
          '✅ StoryRepository: Descripción de imagen generada exitosamente');
      debugPrint('   Longitud de la descripción: ${text.length} caracteres');

      return text;
    } catch (e) {
      debugPrint('❌ StoryRepository: Error durante el análisis de imagen');
      debugPrint('   Error detallado: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAllStoriesForUser(String userId) async {
    await _localDatasource.deleteAllStoriesForUser(userId);
  }

  String _getLanguageName(String? languageCode) {
    switch (languageCode?.toLowerCase()) {
      case 'es':
        return 'español';
      case 'en':
        return 'inglés';
      default:
        debugPrint(
            "⚠️ StoryRepository: Código de idioma no reconocido o nulo ('$languageCode'), usando español por defecto.");
        return 'español';
    }
  }
}
