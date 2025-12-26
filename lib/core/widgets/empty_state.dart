import 'package:flutter/material.dart';
import 'package:memorysparks/core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final double? iconSize;
  final double? fontSize;

  const EmptyState({
    super.key,
    required this.message,
    this.iconSize = 48.0,
    this.fontSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: iconSize,
            color: colors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: fontSize,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
