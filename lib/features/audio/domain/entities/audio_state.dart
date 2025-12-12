import 'package:equatable/equatable.dart';

enum AudioStatus {
  idle,
  loading,
  generating,
  downloading,
  ready,
  playing,
  paused,
  error,
}

class AudioState extends Equatable {
  final AudioStatus status;
  final String? audioUrl;
  final String? localPath;
  final Duration duration;
  final Duration position;
  final double playbackSpeed;
  final double backgroundMusicVolume;
  final String? errorMessage;
  final int? storyId;
  final String? contentHash; // To detect if story content changed

  const AudioState({
    this.status = AudioStatus.idle,
    this.audioUrl,
    this.localPath,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.playbackSpeed = 1.0,
    this.backgroundMusicVolume = 0.25,
    this.errorMessage,
    this.storyId,
    this.contentHash,
  });

  bool get isPlaying => status == AudioStatus.playing;
  bool get isPaused => status == AudioStatus.paused;
  bool get isLoading =>
      status == AudioStatus.loading ||
      status == AudioStatus.generating ||
      status == AudioStatus.downloading;
  bool get isReady =>
      status == AudioStatus.ready ||
      status == AudioStatus.playing ||
      status == AudioStatus.paused;
  bool get hasError => status == AudioStatus.error;
  bool get hasAudio => localPath != null || audioUrl != null;

  double get progress => duration.inMilliseconds > 0
      ? position.inMilliseconds / duration.inMilliseconds
      : 0.0;

  String get formattedPosition => _formatDuration(position);
  String get formattedDuration => _formatDuration(duration);
  String get formattedRemaining => _formatDuration(duration - position);

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final hours = d.inHours.toString();
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  AudioState copyWith({
    AudioStatus? status,
    String? audioUrl,
    String? localPath,
    Duration? duration,
    Duration? position,
    double? playbackSpeed,
    double? backgroundMusicVolume,
    String? errorMessage,
    int? storyId,
    String? contentHash,
  }) {
    return AudioState(
      status: status ?? this.status,
      audioUrl: audioUrl ?? this.audioUrl,
      localPath: localPath ?? this.localPath,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      backgroundMusicVolume:
          backgroundMusicVolume ?? this.backgroundMusicVolume,
      errorMessage: errorMessage ?? this.errorMessage,
      storyId: storyId ?? this.storyId,
      contentHash: contentHash ?? this.contentHash,
    );
  }

  @override
  List<Object?> get props => [
        status,
        audioUrl,
        localPath,
        duration,
        position,
        playbackSpeed,
        backgroundMusicVolume,
        errorMessage,
        storyId,
        contentHash,
      ];
}
