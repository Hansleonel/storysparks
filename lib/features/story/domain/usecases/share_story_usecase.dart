import '../entities/story.dart';

/// Configuración de traducciones para compartir historias
class ShareTranslations {
  final String genre;
  final String generatedWith;
  final String story;
  final String details;
  final String rating;
  final String generatedWithAI;
  final String downloadApp;
  final String continues;

  const ShareTranslations({
    required this.genre,
    required this.generatedWith,
    required this.story,
    required this.details,
    required this.rating,
    required this.generatedWithAI,
    required this.downloadApp,
    required this.continues,
  });
}

class ShareStoryUseCase {
  ShareStoryUseCase();

  /// Formatea una historia para compartir como texto simple
  String executeSimple(
    Story story,
    String appName,
    ShareTranslations translations,
  ) {
    return '''
📚 ${story.title}

${_getStoryPreview(story.content, translations)}

✨ ${translations.genre}: ${story.genre}
⭐ ${translations.generatedWith} $appName

#MemorySparks #${translations.story} #${story.genre} #IA
''';
  }

  /// Formatea una historia para compartir con estilo elegante
  String executeStyled(
    Story story,
    String appName,
    ShareTranslations translations,
  ) {
    return '''
      ╭─────────────────────────╮
      │    🌟 MemorySparks 🌟    │
      ╰─────────────────────────╯

📖 ${story.title.toUpperCase()}

${_addTextDecorations(story.content, translations)}

┌─ ${translations.details.toUpperCase()} ─┐
│ 🎭 ${translations.genre}: ${story.genre}
│ ⭐ ${translations.rating}: ${story.rating.toStringAsFixed(1)}/5.0
│ 📅 ${_formatDate(story.createdAt)}
└─────────────┘

✨ ${translations.generatedWithAI} $appName
🚀 ${translations.downloadApp}

#MemorySparks #${translations.story} #${story.genre} #IA #GenerativeAI
''';
  }

  /// Obtiene una preview de la historia
  String _getStoryPreview(String content, ShareTranslations translations) {
    const maxLength = 2000;
    if (content.length <= maxLength) {
      return content;
    }

    // Buscar un punto final cerca del límite para hacer un corte más natural
    final cutPoint = content.lastIndexOf('.', maxLength);
    if (cutPoint > maxLength - 200) {
      return '${content.substring(0, cutPoint + 1)}\n\n${translations.continues}';
    }

    return '${content.substring(0, maxLength)}...';
  }

  /// Añade decoraciones de texto
  String _addTextDecorations(String content, ShareTranslations translations) {
    final preview = _getStoryPreview(content, translations);
    final lines = preview.split('\n');
    final decoratedLines = <String>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (i == 0) {
        decoratedLines.add('✦ $line');
      } else if (i == lines.length - 1) {
        decoratedLines.add('⟶ $line');
      } else {
        decoratedLines.add('  $line');
      }
    }

    return decoratedLines.join('\n');
  }

  /// Formatea la fecha de manera legible
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
