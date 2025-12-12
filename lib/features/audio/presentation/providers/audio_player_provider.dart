import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:memorysparks/features/audio/domain/entities/audio_state.dart';
import 'package:memorysparks/features/audio/domain/usecases/generate_story_audio_usecase.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioPlayerProvider extends ChangeNotifier {
  final GenerateStoryAudioUseCase _generateAudioUseCase;
  final AudioPlayer _audioPlayer;

  // Background music player - uses audioplayers package (separate from just_audio)
  // This avoids the just_audio_background single instance limitation
  ap.AudioPlayer? _backgroundMusicPlayer;
  bool _backgroundMusicInitialized = false;
  static const String _backgroundMusicVolumeKey = 'background_music_volume';

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
    _loadSavedBackgroundMusicVolume();
  }

  AudioState get state => _state;
  Story? get currentStory => _currentStory;
  bool get isPlaying => _state.isPlaying;
  bool get isPaused => _state.isPaused;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  bool get isReady => _state.isReady;
  double get backgroundMusicVolume => _state.backgroundMusicVolume;

  /// Load saved background music volume from SharedPreferences
  Future<void> _loadSavedBackgroundMusicVolume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVolume = prefs.getDouble(_backgroundMusicVolumeKey);
      if (savedVolume != null) {
        _updateState(_state.copyWith(backgroundMusicVolume: savedVolume));
        debugPrint(
            '🎵 AudioPlayerProvider: Loaded saved background music volume: $savedVolume');
      }
    } catch (e) {
      debugPrint('⚠️ AudioPlayerProvider: Error loading saved volume - $e');
    }
  }

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
        // Stop background music when narration completes
        _stopBackgroundMusic();
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

  // ============ Background Music Methods ============

  /// Initialize background music from asset
  /// Uses audioplayers package (separate from just_audio) to avoid
  /// the just_audio_background single instance limitation
  Future<bool> _initializeBackgroundMusic() async {
    debugPrint('🎵🎵🎵 _initializeBackgroundMusic() called');
    debugPrint('🎵 _backgroundMusicInitialized: $_backgroundMusicInitialized');
    debugPrint('🎵 _backgroundMusicPlayer: $_backgroundMusicPlayer');

    if (_backgroundMusicInitialized && _backgroundMusicPlayer != null) {
      debugPrint('🎵 Already initialized, returning true');
      return true;
    }

    try {
      debugPrint('🎵 Creating new ap.AudioPlayer...');

      // Create a new AudioPlayer using audioplayers package
      // This is completely separate from just_audio
      _backgroundMusicPlayer = ap.AudioPlayer();
      debugPrint('🎵 AudioPlayer created: $_backgroundMusicPlayer');

      // Set the source as an asset
      debugPrint('🎵 Setting source asset: audio/dreamland.mp3');
      await _backgroundMusicPlayer!.setSourceAsset('audio/dreamland.mp3');
      debugPrint('🎵 Source asset set successfully');

      // Set loop mode
      debugPrint('🎵 Setting release mode to loop...');
      await _backgroundMusicPlayer!.setReleaseMode(ap.ReleaseMode.loop);
      debugPrint('🎵 Release mode set to loop');

      // Set initial volume
      debugPrint('🎵 Setting volume to: ${_state.backgroundMusicVolume}');
      await _backgroundMusicPlayer!.setVolume(_state.backgroundMusicVolume);
      debugPrint('🎵 Volume set successfully');

      _backgroundMusicInitialized = true;
      debugPrint(
          '✅✅✅ Background music initialized successfully! Ready to play.');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌❌❌ Error initializing background music');
      debugPrint('❌ Error: $e');
      debugPrint('❌ Stack: $stackTrace');
      debugPrint(
          '💡 Tip: Make sure to run "flutter pub get" and rebuild the app');
      _backgroundMusicInitialized = false;
      _backgroundMusicPlayer?.dispose();
      _backgroundMusicPlayer = null;
      return false;
    }
  }

  /// Set background music from a source (asset or URL)
  /// Prepared for future use with server-hosted audio or genre-specific tracks
  /// Returns true if successful, false otherwise
  Future<bool> setBackgroundMusic(String source, {bool isAsset = true}) async {
    try {
      debugPrint(
          '🎵 AudioPlayerProvider: Setting background music: $source (isAsset: $isAsset)');

      // Create player if it doesn't exist
      _backgroundMusicPlayer ??= ap.AudioPlayer();

      if (isAsset) {
        // Remove 'assets/' prefix if present for audioplayers
        final assetPath = source.replaceFirst('assets/', '');
        await _backgroundMusicPlayer!.setSourceAsset(assetPath);
      } else {
        await _backgroundMusicPlayer!.setSourceUrl(source);
      }
      await _backgroundMusicPlayer!.setReleaseMode(ap.ReleaseMode.loop);
      await _backgroundMusicPlayer!.setVolume(_state.backgroundMusicVolume);
      _backgroundMusicInitialized = true;
      debugPrint('✅ AudioPlayerProvider: Background music source set');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ AudioPlayerProvider: Error setting background music - $e');
      debugPrint('❌ Stack: $stackTrace');
      _backgroundMusicInitialized = false;
      return false;
    }
  }

  /// Stop background music and reset position
  Future<void> _stopBackgroundMusic() async {
    debugPrint('🎵🎵🎵 _stopBackgroundMusic() called');
    if (!_backgroundMusicInitialized || _backgroundMusicPlayer == null) {
      debugPrint('🎵 Not initialized, skipping stop');
      return;
    }
    try {
      debugPrint('🎵 Calling _backgroundMusicPlayer!.stop()...');
      await _backgroundMusicPlayer!.stop();
      debugPrint('✅🎵 Background music stopped successfully');
    } catch (e) {
      debugPrint('❌🎵 Error stopping background music - $e');
    }
  }

  /// Set background music volume (0.0 to 1.0)
  Future<void> setBackgroundMusicVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    debugPrint(
        '🎵 AudioPlayerProvider: Setting background music volume: $clampedVolume');
    try {
      // Update player volume if it exists
      if (_backgroundMusicPlayer != null) {
        await _backgroundMusicPlayer!.setVolume(clampedVolume);
      }
      _updateState(_state.copyWith(backgroundMusicVolume: clampedVolume));

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_backgroundMusicVolumeKey, clampedVolume);
      debugPrint('✅ AudioPlayerProvider: Background music volume saved');
    } catch (e) {
      debugPrint(
          '❌ AudioPlayerProvider: Error setting background music volume - $e');
    }
  }

  // ============ End Background Music Methods ============

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

  /// Play audio (narration + background music)
  Future<void> play() async {
    debugPrint('');
    debugPrint('▶️▶️▶️ ========== PLAY() CALLED ==========');
    debugPrint(
        '   hasAudio: ${_state.hasAudio}, currentStory: ${_currentStory != null}');

    if (!_state.hasAudio && _currentStory != null) {
      debugPrint(
          '🎤 AudioPlayerProvider: No audio loaded - starting generation...');
      await generateAndPlay();
      return;
    }

    try {
      // Update state FIRST to prevent race conditions
      _updateState(_state.copyWith(status: AudioStatus.playing));

      // Initialize background music BEFORE starting playback (non-blocking)
      // This ensures it's ready when we need it
      if (!_backgroundMusicInitialized || _backgroundMusicPlayer == null) {
        debugPrint('🎵 Pre-initializing background music...');
        await _initializeBackgroundMusic();
      }

      debugPrint('🔊🎵 Starting BOTH narration and background music...');

      // Start both players in parallel for better sync
      await Future.wait([
        _audioPlayer.play().then((_) {
          debugPrint('✅ Narration play() completed');
        }),
        _playBackgroundMusicDirect().then((_) {
          debugPrint('✅ Background music play() completed');
        }),
      ]);

      debugPrint('▶️▶️▶️ ========== PLAY() COMPLETE ==========');
      debugPrint('');
    } catch (e) {
      debugPrint('❌ AudioPlayerProvider: Error playing - $e');
    }
  }

  /// Pause audio (narration + background music)
  Future<void> pause() async {
    debugPrint('');
    debugPrint('⏸️⏸️⏸️ ========== PAUSE() CALLED ==========');
    try {
      // Update state FIRST
      _updateState(_state.copyWith(status: AudioStatus.paused));

      debugPrint('🔊🎵 Pausing BOTH narration and background music...');

      // Pause both players in parallel
      await Future.wait([
        _audioPlayer.pause().then((_) {
          debugPrint('✅ Narration pause() completed');
        }),
        _pauseBackgroundMusicDirect().then((_) {
          debugPrint('✅ Background music pause() completed');
        }),
      ]);

      debugPrint('⏸️⏸️⏸️ ========== PAUSE() COMPLETE ==========');
      debugPrint('');
    } catch (e) {
      debugPrint('❌ AudioPlayerProvider: Error pausing - $e');
    }
  }

  /// Direct play for background music (no initialization check, used in parallel)
  Future<void> _playBackgroundMusicDirect() async {
    if (_backgroundMusicPlayer == null) return;
    try {
      await _backgroundMusicPlayer!.resume();
    } catch (e) {
      debugPrint('❌🎵 Error in _playBackgroundMusicDirect - $e');
    }
  }

  /// Direct pause for background music (used in parallel)
  Future<void> _pauseBackgroundMusicDirect() async {
    if (_backgroundMusicPlayer == null) return;
    try {
      await _backgroundMusicPlayer!.pause();
    } catch (e) {
      debugPrint('❌🎵 Error in _pauseBackgroundMusicDirect - $e');
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
    await _stopBackgroundMusic();

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
    _backgroundMusicPlayer?.dispose();
    super.dispose();
  }
}
