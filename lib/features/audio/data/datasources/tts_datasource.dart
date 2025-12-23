/// Abstract interface for TTS (Text-to-Speech) data sources.
/// Both Replicate and Gemini TTS implementations should implement this interface.
abstract class TTSDataSource {
  /// Generates audio from text using the TTS service.
  ///
  /// Returns either:
  /// - A URL string (for Replicate) - e.g., "https://..."
  /// - A base64 encoded string with prefix (for Gemini) - e.g., "base64:..."
  ///
  /// [text] - The text content to convert to speech
  /// [storyId] - The story ID for logging/tracking purposes
  /// [genre] - Optional genre for styled narration (used by Gemini)
  Future<String> generateAudio({
    required String text,
    required int storyId,
    String? genre,
  });
}
