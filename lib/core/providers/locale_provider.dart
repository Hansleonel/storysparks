import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app locale (language).
///
/// Persists locale preference using SharedPreferences.
/// When locale is null, the system default locale is used.
///
/// Usage in main.dart:
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => LocaleProvider()..loadLocale(),
/// )
/// ```
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const List<String> _supportedLocaleCodes = ['en', 'es'];

  Locale? _locale;
  bool _isLoaded = false;

  /// Current app locale. When null, system default is used.
  Locale? get locale => _locale;

  /// Whether the locale preference has been loaded from storage
  bool get isLoaded => _isLoaded;

  /// Load locale preference from SharedPreferences
  Future<void> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);

      if (localeCode != null && _isSupportedLocale(localeCode)) {
        _locale = Locale(localeCode);
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locale preference: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Set locale explicitly (user selection)
  Future<void> setLocale(Locale newLocale) async {
    if (_locale != newLocale && _isSupportedLocale(newLocale.languageCode)) {
      _locale = newLocale;
      notifyListeners();
      await _saveLocale();
    }
  }

  /// Clear locale preference (revert to system default)
  Future<void> clearLocale() async {
    _locale = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localeKey);
    } catch (e) {
      debugPrint('Error clearing locale preference: $e');
    }
  }

  /// Save locale preference to SharedPreferences
  Future<void> _saveLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, _locale!.languageCode);
    } catch (e) {
      debugPrint('Error saving locale preference: $e');
    }
  }

  /// Check if a locale code is supported
  bool _isSupportedLocale(String code) {
    return _supportedLocaleCodes.contains(code);
  }
}
