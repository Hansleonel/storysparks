import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;
  static const String _settingsKey = 'app_settings';

  SettingsRepositoryImpl(this._prefs);

  @override
  Future<Map<String, dynamic>> getSettings() async {
    final String? settingsJson = _prefs.getString(_settingsKey);
    if (settingsJson == null) {
      return {};
    }
    return Map<String, dynamic>.from(jsonDecode(settingsJson));
  }

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings));
  }

  @override
  Future<void> updateSetting(String key, dynamic value) async {
    final settings = await getSettings();
    settings[key] = value;
    await saveSettings(settings);
  }

  @override
  Future<void> clearSettings() async {
    await _prefs.remove(_settingsKey);
  }
}
