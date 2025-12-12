import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/features/audio/domain/entities/audio_state.dart';
import 'package:memorysparks/features/audio/presentation/providers/audio_player_provider.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';
import 'package:memorysparks/l10n/app_localizations.dart';

class AudioPlayerPage extends StatefulWidget {
  final Story story;

  const AudioPlayerPage({
    super.key,
    required this.story,
  });

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage>
    with TickerProviderStateMixin {
  late AnimationController _vinylController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    debugPrint('\n🎵 ========== AudioPlayerPage: initState ==========');
    debugPrint('📖 Story: "${widget.story.title}" (ID: ${widget.story.id})');

    // Vinyl rotation animation - 4 seconds per full rotation
    _vinylController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Wave animation controller - faster for reactive feel
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize audio after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
          '🚀 AudioPlayerPage: PostFrameCallback - initializing audio...');
      context.read<AudioPlayerProvider>().initializeForStory(widget.story);
    });

    debugPrint('🎵 ========== initState complete ==========\n');
  }

  @override
  void dispose() {
    debugPrint('🎵 AudioPlayerPage: dispose() called');
    _vinylController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _updateVinylAnimation(bool isPlaying) {
    if (isPlaying) {
      _vinylController.repeat();
      _waveController.repeat();
    } else {
      _vinylController.stop();
      _waveController.stop();
    }
  }

  void _showBackgroundMusicSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Capture the provider before showing the modal
    // because the modal's context doesn't have access to it
    final provider = context.read<AudioPlayerProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        // Use ListenableBuilder to rebuild when provider changes
        return ListenableBuilder(
          listenable: provider,
          builder: (context, _) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle indicator
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Row(
                    children: [
                      Icon(
                        Icons.music_note_rounded,
                        color: AppColors.goldPremium,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.backgroundMusic,
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Volume label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.volume,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${(provider.backgroundMusicVolume * 100).round()}%',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldPremium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Volume slider
                  Row(
                    children: [
                      Icon(
                        Icons.volume_off_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(modalContext).copyWith(
                            activeTrackColor: AppColors.goldPremium,
                            inactiveTrackColor:
                                AppColors.goldPremium.withOpacity(0.2),
                            thumbColor: AppColors.goldPremium,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16),
                            overlayColor:
                                AppColors.goldPremium.withOpacity(0.2),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: provider.backgroundMusicVolume,
                            min: 0.0,
                            max: 1.0,
                            onChanged: (value) {
                              provider.setBackgroundMusicVolume(value);
                            },
                          ),
                        ),
                      ),
                      Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Preset buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildVolumePresetButton(provider, 0.0, l10n.off),
                      _buildVolumePresetButton(provider, 0.15, '15%'),
                      _buildVolumePresetButton(provider, 0.25, '25%'),
                      _buildVolumePresetButton(provider, 0.50, '50%'),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVolumePresetButton(
    AudioPlayerProvider provider,
    double volume,
    String label,
  ) {
    final isSelected = (provider.backgroundMusicVolume - volume).abs() < 0.01;
    return GestureDetector(
      onTap: () => provider.setBackgroundMusicVolume(volume),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldPremium : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.goldPremium : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Background music settings button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.music_note_rounded,
                color: AppColors.goldPremium,
                size: 20,
              ),
            ),
            onPressed: () => _showBackgroundMusicSettings(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AudioPlayerProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              // Background gradient
              _buildBackground(),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Album art / Story cover
                    Expanded(
                      child: _buildCoverArt(provider),
                    ),

                    // Story info
                    _buildStoryInfo(),

                    const SizedBox(height: 12),

                    // Progress bar
                    _buildProgressBar(provider),

                    const SizedBox(height: 4),

                    // Time indicators
                    _buildTimeIndicators(provider),

                    const SizedBox(height: 12),

                    // Playback controls
                    _buildPlaybackControls(provider),

                    const SizedBox(height: 8),

                    // Speed control
                    _buildSpeedControl(provider),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Loading overlay
              if (provider.isLoading) _buildLoadingOverlay(provider),

              // Error overlay
              if (provider.hasError) _buildErrorOverlay(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.goldPremium.withOpacity(0.15),
            AppColors.background,
            AppColors.background,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }

  Widget _buildCoverArt(AudioPlayerProvider provider) {
    // Update vinyl animation based on playing state
    _updateVinylAnimation(provider.isPlaying);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 55),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rotating disc with full cover image
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shadow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPremium.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),

                // Rotating disc
                AnimatedBuilder(
                  animation: _vinylController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _vinylController.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.goldPremium,
                        width: 4,
                      ),
                    ),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Full cover image
                          widget.story.customImagePath != null
                              ? Image.file(
                                  File(widget.story.customImagePath!),
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  widget.story.imageUrl,
                                  fit: BoxFit.cover,
                                ),

                          // Subtle vinyl overlay effect
                          Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.1),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.05),
                                ],
                                stops: const [0.0, 0.3, 0.6, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Center hole decoration
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(
                      color: AppColors.goldPremium,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Audio waveform visualization
          if (provider.state.localPath != null) _buildRealWaveform(provider),
        ],
      ),
    );
  }

  Widget _buildRealWaveform(AudioPlayerProvider provider) {
    return _buildReactiveEqualizer(provider.isPlaying);
  }

  /// Reactive equalizer visualization that animates when playing
  /// Simulates audio intensity with organic wave patterns
  Widget _buildReactiveEqualizer(bool isPlaying) {
    return SizedBox(
      height: 45,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(25, (index) {
              // Create organic wave pattern with multiple frequencies
              final time = _waveController.value * 2 * math.pi;

              // Different frequency components for each bar
              final freq1 = (index * 0.3 + time * 2).abs();
              final freq2 = (index * 0.5 + time * 3).abs();
              final freq3 = (index * 0.2 + time * 1.5).abs();

              // Combine frequencies for natural look
              final wave1 = (freq1 % (2 * math.pi)).abs();
              final wave2 = (freq2 % (2 * math.pi)).abs();
              final wave3 = (freq3 % (2 * math.pi)).abs();

              // Create height variation pattern
              // Middle bars tend to be taller (like a real EQ)
              final centerFactor = 1.0 - ((index - 12).abs() / 15.0);

              // Pseudo-random variation per bar based on index
              final randomFactor = ((index * 7 + 3) % 11) / 11.0;

              // Calculate dynamic height
              double height;
              if (isPlaying) {
                // Sin waves with different phases create organic movement
                final sinValue = (wave1 * 0.4 + wave2 * 0.35 + wave3 * 0.25);
                final normalized = (sinValue / (2 * math.pi)).clamp(0.0, 1.0);

                // Add randomness and center bias
                final intensity = normalized *
                    (0.5 + randomFactor * 0.5) *
                    (0.6 + centerFactor * 0.4);

                // Map to height range
                height = 6 + (intensity * 35);
              } else {
                // Static low height when paused
                height = 4;
              }

              return AnimatedContainer(
                duration: Duration(milliseconds: isPlaying ? 150 : 400),
                curve: isPlaying ? Curves.easeOut : Curves.easeInOut,
                width: 3.5,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: isPlaying
                        ? [
                            AppColors.goldPremium,
                            AppColors.goldPremium.withOpacity(0.7),
                            AppColors.goldPremium.withOpacity(0.4),
                          ]
                        : [
                            AppColors.goldPremium.withOpacity(0.4),
                            AppColors.goldPremium.withOpacity(0.3),
                          ],
                  ),
                  boxShadow: isPlaying && height > 20
                      ? [
                          BoxShadow(
                            color: AppColors.goldPremium.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildStoryInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            widget.story.title.isNotEmpty
                ? widget.story.title
                : AppLocalizations.of(context)!.yourStory,
            style: const TextStyle(
              fontFamily: 'Playfair',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.goldPremium.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.goldPremium.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_stories,
                  size: 14,
                  color: AppColors.goldPremium,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.story.genre,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.goldPremium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(AudioPlayerProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: AppColors.goldPremium,
          inactiveTrackColor: AppColors.goldPremium.withOpacity(0.2),
          thumbColor: AppColors.goldPremium,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          overlayColor: AppColors.goldPremium.withOpacity(0.2),
          trackHeight: 4,
        ),
        child: Slider(
          value: provider.state.progress.clamp(0.0, 1.0),
          onChanged: provider.isReady
              ? (value) {
                  final position = Duration(
                    milliseconds:
                        (value * provider.state.duration.inMilliseconds)
                            .toInt(),
                  );
                  provider.seekTo(position);
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildTimeIndicators(AudioPlayerProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            provider.state.formattedPosition,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            provider.state.formattedDuration,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(AudioPlayerProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Backward 10s
          _buildControlButton(
            icon: Icons.replay_10_rounded,
            size: 32,
            onPressed:
                provider.isReady ? () => provider.seekBackward(10) : null,
          ),

          // Play/Pause button
          _buildPlayPauseButton(provider),

          // Forward 10s
          _buildControlButton(
            icon: Icons.forward_10_rounded,
            size: 32,
            onPressed: provider.isReady ? () => provider.seekForward(10) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton(AudioPlayerProvider provider) {
    final bool canPlay =
        provider.isReady || provider.state.status == AudioStatus.idle;

    return GestureDetector(
      onTap: canPlay ? () => provider.togglePlayPause() : null,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.goldPremium,
              AppColors.goldPremium.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldPremium.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size,
      color: onPressed != null
          ? AppColors.textPrimary
          : AppColors.textSecondary.withOpacity(0.5),
    );
  }

  Widget _buildSpeedControl(AudioPlayerProvider provider) {
    final speeds = [0.75, 1.0, 1.5];
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            l10n.audioPlaybackSpeed,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: speeds.map((speed) {
              final isSelected = provider.state.playbackSpeed == speed;
              return GestureDetector(
                onTap: provider.isReady
                    ? () => provider.setPlaybackSpeed(speed)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.goldPremium : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.goldPremium : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${speed}x',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(AudioPlayerProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    String message;
    switch (provider.state.status) {
      case AudioStatus.generating:
        message = l10n.audioGenerating;
        break;
      case AudioStatus.downloading:
        message = l10n.audioDownloading;
        break;
      default:
        message = l10n.audioLoading;
    }

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.goldPremium,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.audioPleaseWait,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(AudioPlayerProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.audioError,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.state.errorMessage ?? l10n.audioErrorGenerate,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.audioGoBack,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => provider.regenerateAudio(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldPremium,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.audioTryAgain,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
