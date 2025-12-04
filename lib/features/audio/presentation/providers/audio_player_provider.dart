import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:memorysparks/features/audio/domain/entities/audio_state.dart';
import 'package:memorysparks/features/audio/domain/usecases/generate_story_audio_usecase.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';

class AudioPlayerProvider extends ChangeNotifier {
  final GenerateStoryAudioUseCase _generateAudioUseCase;
  final AudioPlayer _audioPlayer;

  AudioState _state = const AudioState();
  Story? _currentStory;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  AudioPlayerProvider({
    required GenerateStoryAudioUseCase generateAudioUseCase,
    AudioPlayer? audioPlayer,
  })  : _generateAudioUseCase = generateAudioUseCase,
        _audioPlayer = audioPlayer ?? AudioPlayer() {
    _initializeListeners();
  }

  AudioState get state => _state;
  Story? get currentStory => _currentStory;
  bool get isPlaying => _state.isPlaying;
  bool get isPaused => _state.isPaused;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  bool get isReady => _state.isReady;

  void _initializeListeners() {
    debugPrint('🎧 AudioPlayerProvider: Initializing listeners...');

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _updateState(_state.copyWith(position: position));
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        debugPrint(
            '⏱️ AudioPlayerProvider: Duration updated: ${duration.inSeconds}s');
        _updateState(_state.copyWith(duration: duration));
      }
    });

    _playerStateSubscription =
        _audioPlayer.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;
      final playing = playerState.playing;
      debugPrint(
          '🔄 AudioPlayerProvider: Player state changed - processing: $processingState, playing: $playing');

      if (processingState == ProcessingState.completed) {
        debugPrint('✅ AudioPlayerProvider: Playback completed');
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
        _updateState(_state.copyWith(
          status: AudioStatus.paused,
          position: Duration.zero,
        ));
      } else if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        if (!_state.isLoading) {
          debugPrint('⏳ AudioPlayerProvider: Buffering...');
          _updateState(_state.copyWith(status: AudioStatus.loading));
        }
      } else if (processingState == ProcessingState.ready) {
        debugPrint('✅ AudioPlayerProvider: Ready to play');
        _updateState(_state.copyWith(
          status: playing ? AudioStatus.playing : AudioStatus.paused,
        ));
      }
    });

    debugPrint('✅ AudioPlayerProvider: Listeners initialized');
  }

  void _updateState(AudioState newState) {
    if (_state.status != newState.status) {
      debugPrint(
          '📊 AudioPlayerProvider: Status changed: ${_state.status} → ${newState.status}');
    }
    _state = newState;
    notifyListeners();
  }

  /// Initialize audio for a story
  Future<void> initializeForStory(Story story) async {
    debugPrint(
        '\n🎬 ========== AudioPlayerProvider: initializeForStory ==========');
    debugPrint('📖 Story: "${story.title}" (ID: ${story.id})');
    debugPrint('📝 Content length: ${story.content.length} chars');

    _currentStory = story;

    if (story.id == null) {
      debugPrint('❌ AudioPlayerProvider: Story ID is null - cannot initialize');
      _updateState(_state.copyWith(
        status: AudioStatus.error,
        errorMessage: 'Story must be saved first',
      ));
      return;
    }

    // Check if we need to regenerate
    debugPrint('🔍 AudioPlayerProvider: Checking if regeneration needed...');
    final needsRegen = await _generateAudioUseCase.needsRegeneration(story);
    debugPrint('📊 AudioPlayerProvider: needsRegeneration = $needsRegen');

    _updateState(AudioState(
      status: needsRegen ? AudioStatus.idle : AudioStatus.loading,
      storyId: story.id,
    ));

    if (!needsRegen) {
      debugPrint('📦 AudioPlayerProvider: Loading cached audio...');
      await _loadCachedAudio(story);
    } else {
      debugPrint(
          '⏸️ AudioPlayerProvider: Waiting for user to press play (idle state)');
    }

    debugPrint('🎬 ========== initializeForStory complete ==========\n');
  }

  /// Generate and play audio for the current story
  Future<void> generateAndPlay() async {
    debugPrint(
        '\n🎤 ========== AudioPlayerProvider: generateAndPlay ==========');

    if (_currentStory == null) {
      debugPrint('❌ AudioPlayerProvider: No current story - aborting');
      return;
    }

    debugPrint('🔄 AudioPlayerProvider: Setting status to GENERATING');
    _updateState(_state.copyWith(status: AudioStatus.generating));

    debugPrint('🎯 AudioPlayerProvider: Calling GenerateStoryAudioUseCase...');
    final result = await _generateAudioUseCase.execute(_currentStory!);

    result.fold(
      (failure) {
        debugPrint('❌ AudioPlayerProvider: Generation failed!');
        debugPrint('   Error: ${failure.message}');
        _updateState(_state.copyWith(
          status: AudioStatus.error,
          errorMessage: failure.message,
        ));
      },
      (localPath) async {
        debugPrint('✅ AudioPlayerProvider: Audio generation successful!');
        debugPrint('📂 Local path: $localPath');
        _updateState(_state.copyWith(
          status: AudioStatus.downloading,
          localPath: localPath,
        ));
        debugPrint('▶️ AudioPlayerProvider: Loading and playing...');
        await _loadAndPlay(localPath);
      },
    );

    debugPrint('🎤 ========== generateAndPlay complete ==========\n');
  }

  Future<void> _loadCachedAudio(Story story) async {
    debugPrint('📦 AudioPlayerProvider: _loadCachedAudio starting...');
    final result = await _generateAudioUseCase.execute(story);

    result.fold(
      (failure) {
        debugPrint(
            '❌ AudioPlayerProvider: Failed to load cached audio - ${failure.message}');
        _updateState(_state.copyWith(
          status: AudioStatus.error,
          errorMessage: failure.message,
        ));
      },
      (localPath) async {
        debugPrint('✅ AudioPlayerProvider: Cached audio found at $localPath');
        await _loadAudio(localPath);
      },
    );
  }

  Future<void> _loadAndPlay(String path) async {
    debugPrint('▶️ AudioPlayerProvider: _loadAndPlay($path)');
    await _loadAudio(path);
    await play();
  }

  Future<void> _loadAudio(String path) async {
    debugPrint('📂 AudioPlayerProvider: _loadAudio($path)');
    try {
      debugPrint(
          '🔊 AudioPlayerProvider: Setting audio source with metadata...');

      // Create audio source with metadata for background playback notifications
      final audioSource = AudioSource.file(
        path,
        tag: MediaItem(
          id: _currentStory?.id?.toString() ?? 'story',
          title: _currentStory?.title ?? 'Story',
          artist: 'StorySparks',
          album: _currentStory?.genre ?? 'Story',
          // Use story image as artwork if available
          artUri: _currentStory?.customImagePath != null
              ? Uri.file(_currentStory!.customImagePath!)
              : null,
        ),
      );

      await _audioPlayer.setAudioSource(audioSource);
      debugPrint('✅ AudioPlayerProvider: Audio source loaded successfully');
      _updateState(_state.copyWith(
        status: AudioStatus.ready,
        localPath: path,
      ));
    } catch (e) {
      debugPrint('❌ AudioPlayerProvider: Error loading audio file - $e');
      _updateState(_state.copyWith(
        status: AudioStatus.error,
        errorMessage: 'Failed to load audio',
      ));
    }
  }

  /// Play audio
  Future<void> play() async {
    debugPrint('▶️ AudioPlayerProvider: play() called');
    debugPrint(
        '   hasAudio: ${_state.hasAudio}, currentStory: ${_currentStory != null}');

    if (!_state.hasAudio && _currentStory != null) {
      debugPrint(
          '🎤 AudioPlayerProvider: No audio loaded - starting generation...');
      await generateAndPlay();
      return;
    }

    try {
      debugPrint('🔊 AudioPlayerProvider: Starting playback...');
      await _audioPlayer.play();
      _updateState(_state.copyWith(status: AudioStatus.playing));
      debugPrint('✅ AudioPlayerProvider: Playback started');
    } catch (e) {
      debugPrint('❌ AudioPlayerProvider: Error playing - $e');
    }
  }

  /// Pause audio
  Future<void> pause() async {
    debugPrint('⏸️ AudioPlayerProvider: pause() called');
    try {
      await _audioPlayer.pause();
      _updateState(_state.copyWith(status: AudioStatus.paused));
      debugPrint('✅ AudioPlayerProvider: Paused');
    } catch (e) {
      debugPrint('❌ AudioPlayerProvider: Error pausing - $e');
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    debugPrint(
        '🔄 AudioPlayerProvider: togglePlayPause() - current: ${_state.status}');
    if (_state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Seek to position
  Future<void> seekTo(Duration position) async {
    debugPrint('⏩ AudioPlayerProvider: seekTo(${position.inSeconds}s)');
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('❌ AudioPlayerProvider: Error seeking - $e');
    }
  }

  /// Seek forward by seconds
  Future<void> seekForward([int seconds = 10]) async {
    debugPrint('⏩ AudioPlayerProvider: seekForward($seconds s)');
    final newPosition = _state.position + Duration(seconds: seconds);
    final clampedPosition =
        newPosition > _state.duration ? _state.duration : newPosition;
    await seekTo(clampedPosition);
  }

  /// Seek backward by seconds
  Future<void> seekBackward([int seconds = 10]) async {
    debugPrint('⏪ AudioPlayerProvider: seekBackward($seconds s)');
    final newPosition = _state.position - Duration(seconds: seconds);
    final clampedPosition =
        newPosition < Duration.zero ? Duration.zero : newPosition;
    await seekTo(clampedPosition);
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    debugPrint('⚡ AudioPlayerProvider: setPlaybackSpeed($speed)');
    try {
      await _audioPlayer.setSpeed(speed);
      _updateState(_state.copyWith(playbackSpeed: speed));
      debugPrint('✅ AudioPlayerProvider: Speed set to $speed');
    } catch (e) {
      debugPrint('❌ AudioPlayerProvider: Error setting speed - $e');
    }
  }

  /// Regenerate audio (useful when story content changed)
  Future<void> regenerateAudio() async {
    debugPrint('🔄 AudioPlayerProvider: regenerateAudio() called');
    if (_currentStory == null) {
      debugPrint('❌ AudioPlayerProvider: No current story - aborting');
      return;
    }

    debugPrint('⏹️ AudioPlayerProvider: Stopping current playback...');
    await _audioPlayer.stop();

    debugPrint('🔄 AudioPlayerProvider: Resetting state to GENERATING');
    _updateState(const AudioState(status: AudioStatus.generating));

    debugPrint('🎤 AudioPlayerProvider: Starting new generation...');
    await generateAndPlay();
  }

  /// Check if current story needs audio regeneration
  Future<bool> needsRegeneration() async {
    debugPrint('🔍 AudioPlayerProvider: needsRegeneration() check');
    if (_currentStory == null) {
      debugPrint('⚠️ AudioPlayerProvider: No current story');
      return false;
    }
    final result =
        await _generateAudioUseCase.needsRegeneration(_currentStory!);
    debugPrint('📊 AudioPlayerProvider: needsRegeneration = $result');
    return result;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
