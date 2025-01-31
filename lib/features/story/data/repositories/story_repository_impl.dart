import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:storysparks/core/utils/cover_image_helper.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/story_local_datasource.dart';
import '../managers/chat_session_manager.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryLocalDatasource _localDatasource;
  final GenerativeModel _model;
  // TODO this line is used to create the session manager, need to check if it's working
  late final ChatSessionManager _sessionManager;

  StoryRepositoryImpl(this._localDatasource)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
        ) {
    // TODO this line is used to create the session manager, need to check if it's working
    _sessionManager = ChatSessionManager(_model);
    debugPrint('🗄️ StoryRepository: Inicializado con modelo gemini-1.5-flash');
  }

  @override
  Future<Story> generateStory({
    required String memory,
    required String genre,
    required String userId,
  }) async {
    debugPrint('🗄️ StoryRepository: Iniciando generación de historia');
    debugPrint('🗄️ StoryRepository: Preparando prompt con:');
    debugPrint('   - Memoria (longitud): ${memory.length} caracteres');
    debugPrint('   - Género solicitado: $genre');
    debugPrint('   - ID de usuario: $userId');

    try {
      final prompt = '''
Genera una historia cautivadora basada en este recuerdo personal: "$memory"
El género de la historia debe ser $genre.
La historia debe ser emotiva, detallada y mantener la esencia del recuerdo original.
Escribe la historia en español y usa un lenguaje narrativo y descriptivo.
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
        genre: genre,
        createdAt: DateTime.now(),
        memory: memory,
        userId: userId,
        title: 'Mi Historia de ${genre.toLowerCase()}',
        imageUrl: CoverImageHelper.getCoverImage(genre),
      );

      debugPrint('✅ StoryRepository: Historia creada exitosamente');
      debugPrint('   - Título: ${story.title}');
      debugPrint('   - Fecha: ${story.createdAt}');
      debugPrint('   - URL de imagen: ${story.imageUrl}');

      return story;
    } catch (e) {
      debugPrint('❌ StoryRepository: Error durante la generación');
      debugPrint('   Error detallado: $e');
      _handleError(e);
      rethrow;
    }
  }

  // TODO this method is used to continue the story, need to check if it's working
  @override
  Future<Story> continueStory(Story story) async {
    debugPrint('🗄️ StoryRepository: Iniciando continuación de historia');

    if (story.id == null) {
      throw Exception('No se puede continuar una historia sin ID');
    }

    try {
      final chatSession =
          _sessionManager.getOrCreateSession(story.id.toString(), story);

      const prompt = 'Continúa la narración de forma natural y coherente.';

      debugPrint('🤖 StoryRepository: Solicitando continuación...');
      final response = await chatSession.sendMessage(Content.text(prompt));

      if (response.text == null) {
        throw Exception('No se pudo continuar la historia');
      }

      debugPrint('✅ StoryRepository: Continuación generada exitosamente');

      return story.copyWith(
        content: '${story.content}\n\n${response.text}',
        createdAt: DateTime.now(),
      );
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
  Future<List<Story>> getSavedStories(String userId) async {
    return await _localDatasource.getSavedStories(userId);
  }

  @override
  Future<void> updateRating(int storyId, double rating) async {
    await _localDatasource.updateRating(storyId, rating);
  }

  @override
  Future<void> deleteStory(int storyId) async {
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
}
