import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/features/audio/data/datasources/tts_datasource.dart';
import 'package:memorysparks/features/audio/domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final TTSDataSource _ttsDataSource;
  late final Dio _dio;

  static const String _audioHashPrefix = 'audio_hash_';
  static const String _audioDirName = 'story_audio';

  // Gemini TTS audio parameters (PCM format)
  static const int _geminiSampleRate = 24000;
  static const int _geminiBitsPerSample = 16;
  static const int _geminiChannels = 1;

  AudioRepositoryImpl(this._ttsDataSource) {
    // Create a Dio instance with longer timeouts for audio downloads
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5), // Audio files can be large
    ));
  }

  /// Creates a WAV header for raw PCM data.
  /// Gemini TTS returns raw PCM (LINEAR16) at 24kHz, 16-bit, mono.
  Uint8List _createWavHeader(int pcmDataLength) {
    final byteRate =
        _geminiSampleRate * _geminiChannels * _geminiBitsPerSample ~/ 8;
    final blockAlign = _geminiChannels * _geminiBitsPerSample ~/ 8;
    final fileSize = 36 + pcmDataLength;

    final header = ByteData(44);

    // RIFF chunk descriptor
    header.setUint8(0, 0x52); // 'R'
    header.setUint8(1, 0x49); // 'I'
    header.setUint8(2, 0x46); // 'F'
    header.setUint8(3, 0x46); // 'F'
    header.setUint32(4, fileSize, Endian.little); // File size - 8
    header.setUint8(8, 0x57); // 'W'
    header.setUint8(9, 0x41); // 'A'
    header.setUint8(10, 0x56); // 'V'
    header.setUint8(11, 0x45); // 'E'

    // fmt sub-chunk
    header.setUint8(12, 0x66); // 'f'
    header.setUint8(13, 0x6D); // 'm'
    header.setUint8(14, 0x74); // 't'
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    header.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
    header.setUint16(22, _geminiChannels, Endian.little); // NumChannels
    header.setUint32(24, _geminiSampleRate, Endian.little); // SampleRate
    header.setUint32(28, byteRate, Endian.little); // ByteRate
    header.setUint16(32, blockAlign, Endian.little); // BlockAlign
    header.setUint16(34, _geminiBitsPerSample, Endian.little); // BitsPerSample

    // data sub-chunk
    header.setUint8(36, 0x64); // 'd'
    header.setUint8(37, 0x61); // 'a'
    header.setUint8(38, 0x74); // 't'
    header.setUint8(39, 0x61); // 'a'
    header.setUint32(40, pcmDataLength, Endian.little); // Subchunk2Size

    return header.buffer.asUint8List();
  }

  @override
  Future<Either<Failure, String>> generateAudio({
    required String text,
    required int storyId,
    String? language,
  }) async {
    try {
      debugPrint('🎵 AudioRepository: Generating audio for story $storyId');
      debugPrint('🌍 Language: ${language ?? "not specified"}');
      final audioUrl = await _ttsDataSource.generateAudio(
        text: text,
        storyId: storyId,
        language: language,
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
      debugPrint('📥 AudioRepository: Processing audio for story $storyId');

      // ═══════════════════════════════════════════════════════════════
      // DETECT: base64 (Gemini) vs URL (Replicate)
      // ═══════════════════════════════════════════════════════════════
      if (audioUrl.startsWith('base64:')) {
        // GEMINI: Decode base64 PCM and convert to WAV
        debugPrint(
            '🔷 AudioRepository: Gemini format detected - decoding base64 PCM');

        // Use .wav extension for Gemini (PCM data needs WAV container)
        final localPath = await _getLocalAudioPath(storyId, isWav: true);
        final file = File(localPath);
        await file.parent.create(recursive: true);

        final base64Data = audioUrl.substring(7); // Remove "base64:" prefix
        final pcmBytes = base64Decode(base64Data);

        // Create WAV file with header + PCM data
        final wavHeader = _createWavHeader(pcmBytes.length);
        final wavBytes = Uint8List(wavHeader.length + pcmBytes.length);
        wavBytes.setAll(0, wavHeader);
        wavBytes.setAll(wavHeader.length, pcmBytes);

        await file.writeAsBytes(wavBytes);
        debugPrint(
            '✅ AudioRepository: PCM converted to WAV and saved (${wavBytes.length} bytes)');
        debugPrint('📂 AudioRepository: Audio saved to $localPath');
        return Right(localPath);
      } else {
        // REPLICATE: Download MP3 from URL
        final localPath = await _getLocalAudioPath(storyId, isWav: false);
        final file = File(localPath);
        await file.parent.create(recursive: true);

        debugPrint(
            '🔶 AudioRepository: Replicate format detected - downloading from URL');
        debugPrint('🔗 URL: $audioUrl');
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
        debugPrint('✅ AudioRepository: Downloaded from URL');
        debugPrint('📂 AudioRepository: Audio saved to $localPath');
        return Right(localPath);
      }
    } catch (e) {
      debugPrint('❌ AudioRepository: Error processing audio - $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<String?> getLocalAudioPath(int storyId) async {
    debugPrint(
        '📂 AudioRepository: Getting local audio path for story $storyId');

    // Check for WAV first (Gemini), then MP3 (Replicate)
    final wavPath = await _getLocalAudioPath(storyId, isWav: true);
    final wavFile = File(wavPath);
    if (await wavFile.exists()) {
      final fileSize = await wavFile.length();
      debugPrint('📂 AudioRepository: Found WAV at $wavPath');
      debugPrint(
          '📂 AudioRepository: File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      return wavPath;
    }

    final mp3Path = await _getLocalAudioPath(storyId, isWav: false);
    final mp3File = File(mp3Path);
    if (await mp3File.exists()) {
      final fileSize = await mp3File.length();
      debugPrint('📂 AudioRepository: Found MP3 at $mp3Path');
      debugPrint(
          '📂 AudioRepository: File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      return mp3Path;
    }

    debugPrint('📂 AudioRepository: No audio file found for story $storyId');
    return null;
  }

  @override
  Future<void> deleteLocalAudio(int storyId) async {
    debugPrint('🗑️ AudioRepository: Deleting audio for story $storyId');
    try {
      // Delete both WAV and MP3 if they exist
      final wavPath = await _getLocalAudioPath(storyId, isWav: true);
      final wavFile = File(wavPath);
      if (await wavFile.exists()) {
        await wavFile.delete();
        debugPrint('✅ AudioRepository: WAV file deleted');
      }

      final mp3Path = await _getLocalAudioPath(storyId, isWav: false);
      final mp3File = File(mp3Path);
      if (await mp3File.exists()) {
        await mp3File.delete();
        debugPrint('✅ AudioRepository: MP3 file deleted');
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
    final wavPath = await _getLocalAudioPath(storyId, isWav: true);
    final mp3Path = await _getLocalAudioPath(storyId, isWav: false);

    final wavExists = await File(wavPath).exists();
    final mp3Exists = await File(mp3Path).exists();
    final exists = wavExists || mp3Exists;

    debugPrint(
        '🔍 AudioRepository: hasLocalAudio($storyId) = $exists (wav: $wavExists, mp3: $mp3Exists)');
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

  Future<String> _getLocalAudioPath(int storyId, {bool isWav = false}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final extension = isWav ? 'wav' : 'mp3';
    final path = '${appDir.path}/$_audioDirName/story_${storyId}.$extension';
    return path;
  }
}
