import 'package:flutter/material.dart';
import 'package:storysparks/core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Profile',
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
