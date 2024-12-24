import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';

class StoryRepositoryImpl implements StoryRepository {
  final GenerativeModel _model;

  StoryRepositoryImpl()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
        );

  @override
  Future<Story> generateStory({
    required String memory,
    required String genre,
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
      );
    } catch (e) {
      throw Exception('Error al generar la historia: $e');
    }
  }
}
