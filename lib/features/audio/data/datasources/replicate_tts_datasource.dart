import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memorysparks/features/audio/data/datasources/tts_datasource.dart';

abstract class ReplicateTTSDataSource implements TTSDataSource {
  /// Calls the Supabase Edge Function to generate audio
  /// Returns the URL of the generated audio
  @override
  Future<String> generateAudio({
    required String text,
    required int storyId,
    String? genre, // Not used by Replicate, but required by interface
    String? language, // Language code for voice selection
  });
}

class ReplicateTTSDataSourceImpl implements ReplicateTTSDataSource {
  final SupabaseClient _supabaseClient;

  ReplicateTTSDataSourceImpl(this._supabaseClient);

  @override
  Future<String> generateAudio({
    required String text,
    required int storyId,
    String? genre, // Not used by Replicate
    String? language, // Language code for voice selection
  }) async {
    try {
      debugPrint('\n🎤 ========== ReplicateTTS: generateAudio ==========');
      debugPrint('📌 Story ID: $storyId');
      debugPrint('📝 Text length: ${text.length} characters');
      debugPrint('🌍 Language: ${language ?? "not specified (will use default)"}');
      debugPrint(
          '💰 Estimated cost: \$${(text.length / 1000 * 0.06).toStringAsFixed(4)}');

      debugPrint('🔐 Checking authentication...');
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        debugPrint('❌ ReplicateTTS: No active session!');
        throw Exception('User not authenticated');
      }
      debugPrint('✅ User authenticated: ${session.user.id}');

      debugPrint('🌐 Calling Supabase Edge Function: generate-audio');
      debugPrint('⏳ This may take 30-120 seconds depending on text length...');

      final stopwatch = Stopwatch()..start();

      final response = await _supabaseClient.functions.invoke(
        'generate-audio',
        body: {
          'text': text,
          'storyId': storyId,
          'language': language,
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
        debugPrint('❌ ReplicateTTS: Error response - $errorMessage');
        debugPrint('📄 Full response: ${response.data}');
        throw Exception(errorMessage);
      }

      final data = response.data as Map<String, dynamic>;
      debugPrint('📄 Response data: $data');

      final audioUrl = data['audioUrl'] as String;

      debugPrint('✅ ReplicateTTS: Audio generated successfully!');
      debugPrint('🔗 Audio URL: $audioUrl');
      debugPrint('🎤 ========== generateAudio complete ==========\n');

      return audioUrl;
    } catch (e, stackTrace) {
      debugPrint('❌ ReplicateTTS: Exception occurred!');
      debugPrint('   Error: $e');
      debugPrint('   Stack: $stackTrace');
      rethrow;
    }
  }
}
