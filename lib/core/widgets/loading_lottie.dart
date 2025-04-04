import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:memorysparks/core/theme/app_colors.dart';

class LoadingLottie extends StatelessWidget {
  final String? message;

  const LoadingLottie({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Lottie.asset(
              'assets/animations/lottie/loading_ai.json',
              fit: BoxFit.contain,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
