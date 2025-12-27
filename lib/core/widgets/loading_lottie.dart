import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:memorysparks/core/theme/app_colors.dart';
import 'package:memorysparks/core/theme/app_theme.dart';
import 'package:memorysparks/l10n/app_localizations.dart';

class LoadingLottie extends StatefulWidget {
  final String? message;
  final bool showTypewriterEffect;

  const LoadingLottie({
    super.key,
    this.message,
    this.showTypewriterEffect = false,
  });

  @override
  State<LoadingLottie> createState() => _LoadingLottieState();
}

class _LoadingLottieState extends State<LoadingLottie> {
  late List<String> _messages;
  int _currentMessageIndex = 0;
  String _displayedText = '';
  int _charIndex = 0;
  Timer? _typewriterTimer;
  Timer? _messageRotationTimer;
  Timer? _dotsTimer;
  int _dotsCount = 0;

  @override
  void initState() {
    super.initState();

    if (widget.showTypewriterEffect) {
      _initializeMessages();
      _startTypewriterEffect();
      _startDotsAnimation();
    }
  }

  void _initializeMessages() {
    // Initialize with empty list, will be populated in didChangeDependencies
    _messages = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.showTypewriterEffect && _messages.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      _messages = [
        l10n.generatingStoryMessage1,
        l10n.generatingStoryMessage2,
        l10n.generatingStoryMessage3,
        l10n.generatingStoryMessage4,
        l10n.generatingStoryMessage5,
      ];
    }
  }

  void _startTypewriterEffect() {
    _typewriterTimer =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_charIndex < _messages[_currentMessageIndex].length) {
        setState(() {
          _displayedText =
              _messages[_currentMessageIndex].substring(0, _charIndex + 1);
          _charIndex++;
        });
      } else {
        // Finished typing current message, schedule next message
        _typewriterTimer?.cancel();
        _messageRotationTimer =
            Timer(const Duration(seconds: 2, milliseconds: 500), () {
          setState(() {
            _currentMessageIndex =
                (_currentMessageIndex + 1) % _messages.length;
            _displayedText = '';
            _charIndex = 0;
          });
          _startTypewriterEffect();
        });
      }
    });
  }

  void _startDotsAnimation() {
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        _dotsCount = (_dotsCount + 1) % 4;
      });
    });
  }

  String get _animatedDots {
    return '.' * _dotsCount;
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _messageRotationTimer?.cancel();
    _dotsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Lottie.asset(
            'assets/animations/lottie/loading_ai.json',
            fit: BoxFit.contain,
          ),
        ),
        if (widget.message != null || widget.showTypewriterEffect) ...[
          const SizedBox(height: 20),
          SizedBox(
            height: 50, // Fixed height to prevent layout shifts
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Center(
                child: widget.showTypewriterEffect
                    ? _buildTypewriterText(colors)
                    : Text(
                        widget.message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypewriterText(AppColorsExtension colors) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Center(
        key: ValueKey(_currentMessageIndex),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.accent,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            '$_displayedText$_animatedDots',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.3,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
