import 'dart:io';
import 'dart:ui';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('\n🎵 ========== AudioPlayerPage: initState ==========');
    debugPrint('📖 Story: "${widget.story.title}" (ID: ${widget.story.id})');

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
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
    _pulseController.dispose();
    super.dispose();
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
                    const SizedBox(height: 20),

                    // Album art / Story cover
                    Expanded(
                      flex: 5,
                      child: _buildCoverArt(provider),
                    ),

                    // Story info
                    _buildStoryInfo(),

                    const SizedBox(height: 24),

                    // Progress bar
                    _buildProgressBar(provider),

                    const SizedBox(height: 8),

                    // Time indicators
                    _buildTimeIndicators(provider),

                    const SizedBox(height: 24),

                    // Playback controls
                    _buildPlaybackControls(provider),

                    const SizedBox(height: 16),

                    // Speed control
                    _buildSpeedControl(provider),

                    const SizedBox(height: 32),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = provider.isPlaying ? _pulseAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPremium.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover image
                      widget.story.customImagePath != null
                          ? Image.file(
                              File(widget.story.customImagePath!),
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              widget.story.imageUrl,
                              fit: BoxFit.cover,
                            ),

                      // Subtle gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),

                      // Playing indicator
                      if (provider.isPlaying)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.goldPremium,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildSoundWave(),
                                const SizedBox(width: 6),
                                const Text(
                                  'Playing',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSoundWave() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            final offset = index * 0.2;
            final value = ((_pulseController.value + offset) % 1.0);
            final height = 4 + (value * 8);
            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Playback Speed',
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
    String message;
    switch (provider.state.status) {
      case AudioStatus.generating:
        message = 'Generating audio...';
        break;
      case AudioStatus.downloading:
        message = 'Downloading...';
        break;
      default:
        message = 'Loading...';
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
                  'This may take a moment...',
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
                const Text(
                  'Error',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.state.errorMessage ?? 'Failed to generate audio',
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
                        'Go Back',
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
                      child: const Text(
                        'Try Again',
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
