import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:storysparks/features/auth/domain/usecases/login_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignOutUseCase _signOutUseCase;

  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  User? _currentUser;

  AuthProvider(
    this._loginUseCase,
    this._signInWithAppleUseCase,
    this._signOutUseCase,
  );

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;

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
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
