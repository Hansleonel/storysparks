abstract class SettingsRepository {
  Future<Map<String, dynamic>> getSettings();
  Future<void> saveSettings(Map<String, dynamic> settings);
  Future<void> updateSetting(String key, dynamic value);
  Future<void> clearSettings();
}
