import 'package:flutter/material.dart';
import 'package:storysparks/core/theme/app_colors.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Library',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
