import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/story_local_datasource.dart';
import 'package:flutter/foundation.dart';

class StoryRepositoryImpl implements StoryRepository {
  final StoryLocalDatasource _localDatasource;
  final GenerativeModel _model;

  StoryRepositoryImpl(this._localDatasource)
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
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
  Future<int> saveStory(Story story) async {
    debugPrint('💾 Repository: Guardando historia en base de datos local...');
    try {
      final id = await _localDatasource.saveStory(story);
      debugPrint('✅ Repository: Historia guardada con ID: $id');
      return id;
    } catch (e) {
      debugPrint('❌ Repository: Error al guardar la historia: $e');
      throw Exception('Error al guardar la historia: $e');
    }
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

  @override
  Future<Story> continueStory({
    required Story previousStory,
    required String userId,
  }) async {
    try {
      final prompt = '''
        Continúa esta historia manteniendo el mismo género (${previousStory.genre}) y estilo narrativo:
        Historia anterior: "${previousStory.content}"
        La continuación debe ser coherente y mantener el mismo tono emocional. puedes agregar detalles o eventos que sucedieron en el pasado, ademas de conversaciones que sucedieron entre los personajes.
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw Exception('No se pudo generar la continuación de la historia');
      }

      return Story(
        content: response.text!,
        genre: previousStory.genre,
        memory: previousStory.memory,
        userId: userId,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error al continuar la historia: $e');
    }
  }

  @override
  Future<void> updateStory(Story story) async {
    if (story.id == null) {
      debugPrint('❌ Repository: Intento de actualizar historia sin ID');
      throw Exception('No se puede actualizar una historia sin ID');
    }
    debugPrint('📝 Repository: Actualizando historia ID: ${story.id}');
    try {
      await _localDatasource.updateStory(story);
      debugPrint('✅ Repository: Historia actualizada exitosamente');
    } catch (e) {
      debugPrint('❌ Repository: Error al actualizar la historia: $e');
      throw Exception('Error al actualizar la historia: $e');
    }
  }

  @override
  Future<Story> getStoryById(int storyId) async {
    try {
      return await _localDatasource.getStoryById(storyId);
    } catch (e) {
      throw Exception('Error al obtener la historia: $e');
    }
  }
}
