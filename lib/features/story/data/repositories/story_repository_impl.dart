import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/story_local_datasource.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryLocalDatasource _localDatasource;
  final GenerativeModel _model;
  final Map<int, ChatSession> _storyChatSessions = {};

  StoryRepositoryImpl(this._localDatasource)
      : _model = GenerativeModel(
          model: 'gemini-1.5-pro',
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
        );

  @override
  Future<Story> generateStory({
    required String memory,
    required String genre,
    required String userId,
  }) async {
    try {
      final prompt = '''
Genera una historia cautivadora basada en este recuerdo personal: "$memory"
El género de la historia debe ser $genre.
La historia debe ser emotiva, detallada y mantener la esencia del recuerdo original.
Escribe la historia en español y usa un lenguaje narrativo y descriptivo.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception('No se pudo generar la historia');
      }

      return Story(
        content: response.text!,
        genre: genre,
        createdAt: DateTime.now(),
        memory: memory,
        userId: userId,
      );
    } catch (e) {
      throw Exception('Error al generar la historia: $e');
    }
  }

  @override
  Future<String> continueStory({
    required int storyId,
    required String continuationPrompt,
  }) async {
    try {
      // Obtener la historia original
      final story = await _localDatasource.getStoryById(storyId);
      if (story == null) {
        throw Exception('Historia no encontrada');
      }

      // Verificar si ya existe una sesión
      ChatSession chatSession;
      bool isNewSession = false;

      if (_storyChatSessions.containsKey(storyId)) {
        chatSession = _storyChatSessions[storyId]!;
      } else {
        chatSession = _model.startChat();
        _storyChatSessions[storyId] = chatSession;
        isNewSession = true;
      }

      // Si es una nueva sesión, inicializamos el contexto
      if (isNewSession) {
        final initialContext = '''
Esta es una historia existente que necesita ser continuada. Actúa como si fueras el autor original.
La historia hasta ahora es:

${story.content}

Instrucciones para continuar la historia:
1. Mantén el mismo estilo narrativo y tono emocional y debe de tener al menos 6 parrafos grandes
2. El género es ${story.genre}
3. Mantén la coherencia con la trama y personajes existentes
4. Usa el mismo ambiente y escenario
5. Si hay diálogos, mantén la personalidad de cada personaje
6. Si mencionan nuevos personajes, relaciónalos con la historia existente
7. Añade detalles que enriquezcan la narrativa
8. Termina de una manera que invite a seguir leyendo

Ahora, cuando te pida continuar la historia, responde solo con la continuación directa, como si fuera el siguiente párrafo natural.
''';
        await chatSession.sendMessage(Content.text(initialContext));
      }

      // Enviar el prompt de continuación
      final response = await chatSession.sendMessage(
        Content.text(
            "Continúa la historia con este contexto adicional: $continuationPrompt"),
      );

      if (response.text == null) {
        throw Exception('No se pudo generar la continuación');
      }

      // Actualizar la historia en la base de datos
      final updatedContent = '${story.content}\n\n${response.text}';
      await _localDatasource.updateStoryContent(storyId, updatedContent);

      return response.text!;
    } catch (e) {
      throw Exception('Error al continuar la historia: $e');
    }
  }

  @override
  Future<Story?> getStoryById(int storyId) async {
    return await _localDatasource.getStoryById(storyId);
  }

  // Método para limpiar la sesión si es necesario
  void clearStorySession(int storyId) {
    _storyChatSessions.remove(storyId);
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
