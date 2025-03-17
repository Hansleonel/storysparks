import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatelessWidget {
  final String animationPath;
  final double width;
  final double height;
  final BoxFit fit;
  final bool repeat;
  final bool animate;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const LottieAnimation({
    super.key,
    required this.animationPath,
    this.width = 200,
    this.height = 200,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.animate = true,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final animation = Lottie.asset(
      animationPath,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      animate: animate,
    );

    if (backgroundColor != null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: animation,
      );
    }

    return animation;
  }
}
