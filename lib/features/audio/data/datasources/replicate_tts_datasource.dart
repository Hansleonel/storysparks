import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ReplicateTTSDataSource {
  /// Calls the Supabase Edge Function to generate audio
  /// Returns the URL of the generated audio
  Future<String> generateAudio({
    required String text,
    required int storyId,
  });
}

class ReplicateTTSDataSourceImpl implements ReplicateTTSDataSource {
  final SupabaseClient _supabaseClient;

  ReplicateTTSDataSourceImpl(this._supabaseClient);

  @override
  Future<String> generateAudio({
    required String text,
    required int storyId,
  }) async {
    try {
      debugPrint('\n🎤 ========== ReplicateTTS: generateAudio ==========');
      debugPrint('📌 Story ID: $storyId');
      debugPrint('📝 Text length: ${text.length} characters');
      debugPrint('💰 Estimated cost: \$${(text.length / 1000 * 0.06).toStringAsFixed(4)}');

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
        },
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );
      
      stopwatch.stop();
      debugPrint('⏱️ Edge Function response time: ${stopwatch.elapsedMilliseconds}ms');
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
