import 'package:flutter/foundation.dart';
import 'package:storysparks/core/usecases/usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/logout_usecase.dart';

class SettingsProvider extends ChangeNotifier {
  final LogoutUseCase _logoutUseCase;
  bool _isDarkMode = false;
  String _currentLanguage = 'en';
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  String? _error;

  SettingsProvider(this._logoutUseCase);

  bool get isDarkMode => _isDarkMode;
  String get currentLanguage => _currentLanguage;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  Future<String?> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _logoutUseCase(NoParams());

    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return failure.message;
      },
      (_) {
        _isLoading = false;
        notifyListeners();
        return null;
      },
    );
  }

  Future<void> loadSettings() async {
    // TODO: Implement loading settings from local storage
  }

  Future<void> saveSettings() async {
    // TODO: Implement saving settings to local storage
  }
}
