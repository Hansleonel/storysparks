import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/story.dart';

/// Manages chat sessions for story continuations.
///
/// Maintains active chat sessions and handles their lifecycle,
/// ensuring efficient context management with Gemini.
class ChatSessionManager {
  final Map<String, ChatSession> _sessions = {};
  final GenerativeModel _model;

  ChatSessionManager(this._model);

  /// Gets an existing session or creates a new one with full story context
  ChatSession getOrCreateSession(String storyId, Story story) {
    if (_sessions.containsKey(storyId)) {
      debugPrint(
          '🔄 ChatSessionManager: Reutilizando sesión existente para historia $storyId');
      return _sessions[storyId]!;
    }

    debugPrint(
        '✨ ChatSessionManager: Creando nueva sesión para historia $storyId');
    debugPrint('   Enviando historia completa como contexto inicial');

    final session = _model.startChat(history: [
      Content.text('''
Historia completa hasta ahora:
${story.content}

Información importante:
- Género: ${story.genre}
- Estilo: Mantener el mismo tono narrativo y estilo de escritura
- Memoria original: ${story.memory}
''')
    ]);

    _sessions[storyId] = session;
    return session;
  }

  /// Clears a specific session, useful when encountering errors
  void clearSession(String storyId) {
    debugPrint(
        '🗑️ ChatSessionManager: Limpiando sesión para historia $storyId');
    _sessions.remove(storyId);
  }

  /// Clears all active sessions
  void clearAllSessions() {
    debugPrint('🧹 ChatSessionManager: Limpiando todas las sesiones');
    _sessions.clear();
  }
}
