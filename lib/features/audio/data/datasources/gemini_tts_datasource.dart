import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memorysparks/features/audio/data/datasources/tts_datasource.dart';

/// Datasource for Gemini TTS (Text-to-Speech) using Google's Gemini API.
/// Returns audio as base64 encoded data with "base64:" prefix.
abstract class GeminiTTSDataSource implements TTSDataSource {
  /// Calls the Supabase Edge Function to generate audio using Gemini TTS.
  /// Returns base64 encoded audio data with "base64:" prefix.
  ///
  /// [text] - The story content to convert to speech
  /// [storyId] - The story ID for logging purposes
  /// [genre] - Optional genre for styled narration (e.g., "Romántico", "Aventura")
  /// [language] - Language code (not used by Gemini, but required by interface)
  @override
  Future<String> generateAudio({
    required String text,
    required int storyId,
    String? genre,
    String? language,
  });
}

class GeminiTTSDataSourceImpl implements GeminiTTSDataSource {
  final SupabaseClient _supabaseClient;

  GeminiTTSDataSourceImpl(this._supabaseClient);

  @override
  Future<String> generateAudio({
    required String text,
    required int storyId,
    String? genre,
    String? language, // Not used by Gemini, but required by interface
  }) async {
    try {
      debugPrint('\n🔷 ========== GeminiTTS: generateAudio ==========');
      debugPrint('📌 Story ID: $storyId');
      debugPrint('📝 Text length: ${text.length} characters');
      debugPrint('🎭 Genre: ${genre ?? 'not specified'}');

      debugPrint('🔐 Checking authentication...');
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        debugPrint('❌ GeminiTTS: No active session!');
        throw Exception('User not authenticated');
      }
      debugPrint('✅ User authenticated: ${session.user.id}');

      debugPrint('🌐 Calling Supabase Edge Function: generate-audio-gemini');
      debugPrint('⏳ This may take 30-60 seconds depending on text length...');

      final stopwatch = Stopwatch()..start();

      final response = await _supabaseClient.functions.invoke(
        'generate-audio-gemini',
        body: {
          'text': text,
          'storyId': storyId,
          'genre': genre,
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      stopwatch.stop();
      debugPrint(
          '⏱️ Edge Function response time: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('📡 Response status: ${response.status}');

      if (response.status != 200) {
        final errorData = response.data;
        final errorMessage =
            errorData is Map ? errorData['error'] : 'Unknown error';
        debugPrint('❌ GeminiTTS: Error response - $errorMessage');
        debugPrint('📄 Full response: ${response.data}');
        throw Exception(errorMessage);
      }

      final data = response.data as Map<String, dynamic>;
      debugPrint('📄 Response keys: ${data.keys.toList()}');

      // Gemini returns "base64:{data}" format
      final audioData = data['audioData'] as String;

      debugPrint('✅ GeminiTTS: Audio generated successfully!');
      debugPrint(
          '📦 Audio data length: ${audioData.length} characters (base64)');
      debugPrint('🔷 ========== generateAudio complete ==========\n');

      return audioData;
    } catch (e, stackTrace) {
      debugPrint('❌ GeminiTTS: Exception occurred!');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }
}
