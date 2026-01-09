import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/features/audio/domain/repositories/audio_repository.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';

class GenerateStoryAudioUseCase {
  final AudioRepository _audioRepository;

  GenerateStoryAudioUseCase(this._audioRepository);

  /// Generates or retrieves audio for a story
  /// Returns the local file path of the audio
  Future<Either<Failure, String>> execute(Story story) async {
    debugPrint('🎯 GenerateStoryAudioUseCase: Starting execute()');
    debugPrint('📖 Story ID: ${story.id}, Title: ${story.title}');
    debugPrint('📝 Content length: ${story.content.length} characters');

    if (story.id == null) {
      debugPrint(
          '❌ GenerateStoryAudioUseCase: Story ID is null - cannot generate audio');
      return const Left(
          ServerFailure('Story must be saved before generating audio'));
    }

    final storyId = story.id!;
    final contentHash = _generateContentHash(story.content);
    debugPrint('🔑 Generated content hash: $contentHash');

    // Check if we have cached audio with matching content
    debugPrint('🔍 Checking for cached audio...');
    final existingHash = await _audioRepository.getAudioContentHash(storyId);
    final hasLocalAudio = await _audioRepository.hasLocalAudio(storyId);
    debugPrint('📦 Has local audio: $hasLocalAudio');
    debugPrint('🔑 Existing hash: $existingHash');
    debugPrint('🔄 Hashes match: ${existingHash == contentHash}');

    if (hasLocalAudio && existingHash == contentHash) {
      // Audio is cached and content hasn't changed
      debugPrint('✅ Cache HIT - Using cached audio');
      final localPath = await _audioRepository.getLocalAudioPath(storyId);
      if (localPath != null) {
        debugPrint('📂 Cached audio path: $localPath');
        return Right(localPath);
      }
    }

    debugPrint('🔄 Cache MISS - Need to generate new audio');

    // Need to generate new audio
    // First, clean up old audio if exists
    if (hasLocalAudio) {
      debugPrint('🗑️ Cleaning up old audio file...');
      await _audioRepository.deleteLocalAudio(storyId);
    }

    // Generate audio via TTS service
    debugPrint('🎤 Calling TTS service to generate audio...');
    debugPrint('🌍 Story language: ${story.language}');
    final generateResult = await _audioRepository.generateAudio(
      text: story.content,
      storyId: storyId,
      language: story.language,
    );

    return generateResult.fold(
      (failure) {
        debugPrint(
            '❌ GenerateStoryAudioUseCase: TTS generation failed - ${failure.message}');
        return Left(failure);
      },
      (audioUrl) async {
        debugPrint('✅ TTS generation successful!');
        debugPrint('🔗 Audio URL: $audioUrl');

        // Download and save locally
        debugPrint('📥 Downloading audio to local storage...');
        final downloadResult = await _audioRepository.downloadAndSaveAudio(
          audioUrl: audioUrl,
          storyId: storyId,
        );

        return downloadResult.fold(
          (failure) {
            debugPrint(
                '❌ GenerateStoryAudioUseCase: Download failed - ${failure.message}');
            return Left(failure);
          },
          (localPath) async {
            debugPrint('✅ Audio downloaded successfully!');
            debugPrint('📂 Local path: $localPath');

            // Save content hash for future cache validation
            debugPrint('💾 Saving content hash for cache...');
            await _audioRepository.saveAudioContentHash(storyId, contentHash);
            debugPrint('✅ GenerateStoryAudioUseCase: Complete!');
            return Right(localPath);
          },
        );
      },
    );
  }

  /// Checks if audio needs to be regenerated (content changed)
  Future<bool> needsRegeneration(Story story) async {
    debugPrint('🔍 needsRegeneration: Checking if audio needs regeneration...');

    if (story.id == null) {
      debugPrint('⚠️ Story ID is null - needs generation');
      return true;
    }

    final storyId = story.id!;
    final contentHash = _generateContentHash(story.content);
    final existingHash = await _audioRepository.getAudioContentHash(storyId);
    final hasLocalAudio = await _audioRepository.hasLocalAudio(storyId);

    final needsRegen = !hasLocalAudio || existingHash != contentHash;
    debugPrint('📊 needsRegeneration result: $needsRegen');
    debugPrint('   - hasLocalAudio: $hasLocalAudio');
    debugPrint('   - hashesMatch: ${existingHash == contentHash}');

    return needsRegen;
  }

  String _generateContentHash(String content) {
    // Simple hash based on content length and first/last characters
    // This is sufficient for detecting content changes
    final length = content.length;
    final prefix = content.length > 50 ? content.substring(0, 50) : content;
    final suffix =
        content.length > 50 ? content.substring(content.length - 50) : '';
    return '${length}_${prefix.hashCode}_${suffix.hashCode}';
  }
}
