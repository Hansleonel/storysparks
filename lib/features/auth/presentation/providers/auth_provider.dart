import 'package:flutter/foundation.dart';
import 'package:storysparks/features/auth/data/models/user_model.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  AuthProvider(this._authRepository);

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  Future<UserModel?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // final user = await _authRepository.login(email, password);
      const user = UserModel(
        id: '1',
        email: 'test@test.com',
        name: 'Test',
      );
      _isAuthenticated = true;
      return user;
    } catch (e) {
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authRepository.register(email, password);
      _isAuthenticated = true;
      return user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authRepository.logout();
      if (success) {
        _isAuthenticated = false;
      }
      return success;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
