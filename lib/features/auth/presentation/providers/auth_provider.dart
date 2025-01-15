import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:storysparks/features/auth/domain/entities/profile.dart';
import 'package:storysparks/features/auth/domain/usecases/login_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/register_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignOutUseCase _signOutUseCase;
  final RegisterUseCase _registerUseCase;

  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  User? _currentUser;
  bool _isPasswordVisible = false;
  Profile? _userProfile;

  AuthProvider(
    this._loginUseCase,
    this._signInWithAppleUseCase,
    this._signOutUseCase,
    this._registerUseCase,
  );

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  bool get isPasswordVisible => _isPasswordVisible;
  Profile? get userProfile => _userProfile;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? bio,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _registerUseCase(
        RegisterParams(
          email: email,
          password: password,
          username: username,
          fullName: fullName,
          bio: bio,
        ),
      );

      return result.fold(
        (failure) {
          _error = failure.message;
          _isAuthenticated = false;
          _currentUser = null;
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (profile) {
          _userProfile = profile;
          _isAuthenticated = true;
          _error = null;
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<User?> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _loginUseCase(
        LoginParams(
          email: email,
          password: password,
        ),
      );

      return result.fold(
        (failure) {
          _error = failure.message;
          _isAuthenticated = false;
          _currentUser = null;
          return null;
        },
        (response) {
          _currentUser = response.user;
          _isAuthenticated = true;
          _error = null;
          return _currentUser;
        },
      );
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithApple() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final result = await _signInWithAppleUseCase(
        SignInWithAppleParams(
          idToken: credential.identityToken!,
          accessToken: credential.authorizationCode,
          givenName: credential.givenName,
          familyName: credential.familyName,
        ),
      );

      result.fold(
        (failure) {
          _error = failure.message;
          _isAuthenticated = false;
          _currentUser = null;
        },
        (response) {
          _currentUser = response.user;
          _isAuthenticated = true;
          _error = null;
        },
      );
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    final result = await _signOutUseCase(const NoParams());

    result.fold(
      (failure) => _error = failure.message,
      (_) {
        _isAuthenticated = false;
        _error = null;
        _currentUser = null;
        _userProfile = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
