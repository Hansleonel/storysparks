import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/features/audio/data/datasources/replicate_tts_datasource.dart';
import 'package:memorysparks/features/audio/domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final ReplicateTTSDataSource _ttsDataSource;
  late final Dio _dio;

  static const String _audioHashPrefix = 'audio_hash_';
  static const String _audioDirName = 'story_audio';

  AudioRepositoryImpl(this._ttsDataSource) {
    // Create a Dio instance with longer timeouts for audio downloads
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5), // Audio files can be large
    ));
  }

  @override
  Future<Either<Failure, String>> generateAudio({
    required String text,
    required int storyId,
  }) async {
    try {
      debugPrint('🎵 AudioRepository: Generating audio for story $storyId');
      final audioUrl = await _ttsDataSource.generateAudio(
        text: text,
        storyId: storyId,
      );
      return Right(audioUrl);
    } catch (e) {
      debugPrint('❌ AudioRepository: Error generating audio - $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> downloadAndSaveAudio({
    required String audioUrl,
    required int storyId,
  }) async {
    try {
      debugPrint('📥 AudioRepository: Downloading audio from $audioUrl');

      // Get the local path
      final localPath = await _getLocalAudioPath(storyId);

      // Ensure directory exists
      final file = File(localPath);
      await file.parent.create(recursive: true);

      // Download and save the file using Dio
      await _dio.download(
        audioUrl,
        localPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('📥 Download progress: $progress%');
          }
        },
      );

      debugPrint('✅ AudioRepository: Audio saved to $localPath');
      return Right(localPath);
    } catch (e) {
      debugPrint('❌ AudioRepository: Error downloading audio - $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<String?> getLocalAudioPath(int storyId) async {
    debugPrint(
        '📂 AudioRepository: Getting local audio path for story $storyId');
    final path = await _getLocalAudioPath(storyId);
    final file = File(path);
    final exists = await file.exists();
    debugPrint('📂 AudioRepository: Path: $path, Exists: $exists');
    if (exists) {
      final fileSize = await file.length();
      debugPrint(
          '📂 AudioRepository: File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      return path;
    }
    return null;
  }

  @override
  Future<void> deleteLocalAudio(int storyId) async {
    debugPrint('🗑️ AudioRepository: Deleting audio for story $storyId');
    try {
      final path = await _getLocalAudioPath(storyId);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ AudioRepository: Audio file deleted successfully');
      } else {
        debugPrint('⚠️ AudioRepository: No audio file found to delete');
      }
      // Also delete the hash
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_audioHashPrefix$storyId');
      debugPrint('✅ AudioRepository: Hash removed from preferences');
    } catch (e) {
      debugPrint('❌ AudioRepository: Error deleting audio - $e');
    }
  }

  @override
  Future<bool> hasLocalAudio(int storyId) async {
    final path = await _getLocalAudioPath(storyId);
    final file = File(path);
    final exists = await file.exists();
    debugPrint('🔍 AudioRepository: hasLocalAudio($storyId) = $exists');
    return exists;
  }

  @override
  Future<String?> getAudioContentHash(int storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = prefs.getString('$_audioHashPrefix$storyId');
    debugPrint('🔑 AudioRepository: getAudioContentHash($storyId) = $hash');
    return hash;
  }

  @override
  Future<void> saveAudioContentHash(int storyId, String hash) async {
    debugPrint('💾 AudioRepository: Saving hash for story $storyId: $hash');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_audioHashPrefix$storyId', hash);
    debugPrint('✅ AudioRepository: Hash saved successfully');
  }

  Future<String> _getLocalAudioPath(int storyId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final path = '${appDir.path}/$_audioDirName/story_${storyId}.mp3';
    return path;
  }
}
