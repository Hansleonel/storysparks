import 'package:flutter/material.dart';

/// Light theme color constants.
///
/// For dark mode colors, see [AppColorsDark] in app_theme.dart.
/// For dynamic theme-aware colors, use `context.appColors` extension.
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY & ACCENT
  // ============================================

  /// Primary brand color - Purple
  static const Color primary = Color(0xFF504FF6);

  /// Accent color - Gold for special actions
  static const Color accent = Color(0xFFA69365);

  // ============================================
  // BACKGROUNDS & SURFACES
  // ============================================

  /// Main background color
  static const Color background = Color(0xFFF9FAFB);

  /// White - used for cards, inputs, surfaces
  static const Color white = Color(0xFFFFFFFF);

  // ============================================
  // BORDERS & DIVIDERS
  // ============================================

  /// Border and divider color
  static const Color border = Color(0xFFD1D5DB);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Primary text color - dark gray
  static const Color textPrimary = Color(0xFF1F2937);

  /// Secondary text color - medium gray
  static const Color textSecondary = Color(0xFF6B7280);

  // ============================================
  // STATUS COLORS
  // ============================================

  /// Success state - green
  static const Color success = Color(0xFF34D399);

  /// Error/danger state - red
  static const Color error = Color(0xFFEF4444);

  // ============================================
  // NOTIFICATION & INDICATORS
  // ============================================

  /// Red indicator for "new" badges
  static const Color newIndicator = Color(0xFFEF4444);

  /// Green variant for alternative accents
  static const Color greenVariant = Color(0xFF4CAF93);

  // ============================================
  // CONTEXT QUALITY INDICATORS
  // ============================================

  /// Red - insufficient context
  static const Color contextInsufficient = Color(0xFFEF4444);

  /// Amber/orange - basic context
  static const Color contextBasic = Color(0xFFF59E0B);

  /// Emerald green - good context
  static const Color contextGood = Color(0xFF10B981);

  /// Blue - rich context
  static const Color contextRich = Color(0xFF3B82F6);

  /// Purple - exceptional context
  static const Color contextExceptional = Color(0xFF8B5CF6);

  // ============================================
  // PREMIUM
  // ============================================

  /// Premium gold for special actions (audio player, etc.)
  static const Color goldPremium = Color(0xFFC9A962);
}
