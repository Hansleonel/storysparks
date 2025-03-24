import 'package:flutter/material.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  final double progress;

  const OnboardingProgressIndicator({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.white.withOpacity(0.3),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 4,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
