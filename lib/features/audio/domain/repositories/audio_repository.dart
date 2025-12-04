import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';

abstract class AudioRepository {
  /// Generates audio from text using the TTS service
  /// Returns the URL of the generated audio
  Future<Either<Failure, String>> generateAudio({
    required String text,
    required int storyId,
  });

  /// Downloads audio from URL and saves it locally
  /// Returns the local file path
  Future<Either<Failure, String>> downloadAndSaveAudio({
    required String audioUrl,
    required int storyId,
  });

  /// Gets the local audio file path if it exists
  Future<String?> getLocalAudioPath(int storyId);

  /// Deletes local audio file for a story
  Future<void> deleteLocalAudio(int storyId);

  /// Checks if audio exists locally for a story
  Future<bool> hasLocalAudio(int storyId);

  /// Gets the content hash for a story's audio (to detect changes)
  Future<String?> getAudioContentHash(int storyId);

  /// Saves the content hash for a story's audio
  Future<void> saveAudioContentHash(int storyId, String hash);
}
