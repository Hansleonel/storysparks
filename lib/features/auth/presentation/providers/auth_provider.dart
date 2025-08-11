import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:memorysparks/features/auth/domain/entities/profile.dart';
import 'package:memorysparks/features/auth/domain/usecases/login_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/register_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:memorysparks/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/delete_all_stories_for_user_usecase.dart';
import 'package:memorysparks/features/subscription/presentation/providers/subscription_provider.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignOutUseCase _signOutUseCase;
  final RegisterUseCase _registerUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final DeleteAllStoriesForUserUseCase _deleteAllStoriesForUserUseCase;
  final SubscriptionProvider _subscriptionProvider;

  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  User? _currentUser;
  bool _isPasswordVisible = false;
  Profile? _userProfile;

  AuthProvider(
    this._loginUseCase,
    this._signInWithAppleUseCase,
    this._signInWithGoogleUseCase,
    this._signOutUseCase,
    this._registerUseCase,
    this._deleteAccountUseCase,
    this._deleteAllStoriesForUserUseCase,
    this._subscriptionProvider,
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

  /// Reset loading state after successful navigation
  void resetLoadingState() {
    _isLoading = false;
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
          _isLoading = false; // ✅ Only set loading false on failure
          notifyListeners();
          return null;
        },
        (response) async {
          _currentUser = response.user;

          // 🔑 Initialize RevenueCat with user ID BEFORE setting authenticated
          if (_currentUser?.id != null) {
            try {
              await _subscriptionProvider.initializeWithUser(_currentUser!.id);
              debugPrint(
                  '🟢 RevenueCat initialized for user: ${_currentUser!.id}');
            } catch (e) {
              debugPrint('🔴 Error initializing RevenueCat: $e');
              // Don't fail login if RevenueCat fails
            }
          }

          // ✅ Set authenticated AFTER RevenueCat initialization
          _isAuthenticated = true;
          _error = null;

          // ✅ Keep loading true on success - UI will navigate immediately
          // _isLoading stays true to prevent double login until navigation
          notifyListeners();
          return _currentUser;
        },
      );
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false; // ✅ Only set loading false on exception
      notifyListeners();
      return null;
    }
    // ✅ Removed finally block - loading state managed explicitly
  }

  Future<bool> signInWithApple() async {
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

      return result.fold(
        (failure) {
          _error = failure.message;
          _isAuthenticated = false;
          _currentUser = null;
          _isLoading = false; // ✅ Only set loading false on failure
          notifyListeners();
          return false;
        },
        (response) async {
          _currentUser = response.user;

          // 🔑 Initialize RevenueCat with user ID BEFORE setting authenticated
          if (_currentUser?.id != null) {
            try {
              await _subscriptionProvider.initializeWithUser(_currentUser!.id);
              debugPrint(
                  '🟢 RevenueCat initialized for Apple user: ${_currentUser!.id}');
            } catch (e) {
              debugPrint('🔴 Error initializing RevenueCat (Apple): $e');
              // Don't fail login if RevenueCat fails
            }
          }

          // ✅ Set authenticated AFTER RevenueCat initialization
          _isAuthenticated = true;
          _error = null;

          // ✅ Keep loading true on success - UI will navigate immediately
          // _isLoading stays true to prevent double login until navigation
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false; // ✅ Only set loading false on exception
      notifyListeners();
      return false;
    }
    // ✅ Removed finally block - loading state managed explicitly
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
      final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';

      // Google sign in on Android will work without providing the Android
      // Client ID registered on Google Cloud.

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
        scopes: [
          'email',
          'profile',
          'openid',
        ],
      );

      // Primero desconectamos por si hay una sesión previa
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Sign in was cancelled by the user';
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final result = await _signInWithGoogleUseCase(
        SignInWithGoogleParams(
          idToken: idToken,
          accessToken: accessToken,
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
        (response) async {
          _currentUser = response.user;

          // 🔑 Initialize RevenueCat with user ID BEFORE setting authenticated
          if (_currentUser?.id != null) {
            try {
              await _subscriptionProvider.initializeWithUser(_currentUser!.id);
              debugPrint(
                  '🟢 RevenueCat initialized for Google user: ${_currentUser!.id}');
            } catch (e) {
              debugPrint('🔴 Error initializing RevenueCat (Google): $e');
              // Don't fail login
              // if RevenueCat fails
            }
          }

          // ✅ Set authenticated AFTER RevenueCat initialization
          _isAuthenticated = true;
          _error = null;

          // ✅ Keep loading true on success - UI will navigate immediately
          // _isLoading stays true to prevent double login until navigation
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

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    final result = await _signOutUseCase(NoParams());

    result.fold(
      (failure) => _error = failure.message,
      (_) async {
        // 🔐 Logout from RevenueCat before clearing auth state
        try {
          await _subscriptionProvider.logoutRevenueCat();
          debugPrint('🟢 RevenueCat logout successful');
        } catch (e) {
          debugPrint('🔴 Error during RevenueCat logout: $e');
          // Continue with logout even if RevenueCat fails
        }

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

  Future<bool> deleteAccount() async {
    print('⚠️ AuthProvider: Iniciando proceso de eliminación de cuenta');
    _isLoading = true;
    _error = null;
    notifyListeners();
    print('🔄 AuthProvider: Estado de carga activado, notificando listeners');

    try {
      // Asegúrate de tener el userId antes de borrar para poder limpiar datos locales
      final userId = _currentUser?.id;
      if (userId == null) {
        print('❌ AuthProvider: No hay usuario autenticado para eliminar');
        _error = 'No hay usuario autenticado';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      print('👤 AuthProvider: Usuario identificado: $userId');

      // Usar el UseCase para eliminar la cuenta
      print('🔄 AuthProvider: Llamando a DeleteAccountUseCase');
      final result = await _deleteAccountUseCase(NoParams());

      return result.fold(
        (failure) {
          print(
              '❌ AuthProvider: Error en eliminación de cuenta: ${failure.message}');
          _error = failure.message;
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (_) async {
          print(
              '✅ AuthProvider: Cuenta eliminada en Supabase, procediendo a limpiar datos locales');
          // Borrar datos locales después de eliminar en Supabase
          await deleteLocalData(userId);

          // Limpiar estado
          print('🧹 AuthProvider: Limpiando estado de sesión');
          _userProfile = null;
          _isAuthenticated = false;
          _currentUser = null;
          _isLoading = false;
          notifyListeners();
          print(
              '🏁 AuthProvider: Proceso de eliminación completado exitosamente');
          return true;
        },
      );
    } catch (e) {
      print('💥 AuthProvider: Excepción durante eliminación de cuenta: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteLocalData(String userId) async {
    print(
        '🧹 AuthProvider: Iniciando limpieza de datos locales para usuario: $userId');

    try {
      // Eliminar historias locales
      print('📚 AuthProvider: Eliminando historias locales');
      final deleteStoriesResult = await _deleteAllStoriesForUserUseCase(
          DeleteAllStoriesParams(userId: userId));

      deleteStoriesResult.fold(
          (failure) => print(
              '❌ AuthProvider: Error al eliminar historias: ${failure.message}'),
          (_) => print('✅ AuthProvider: Historias eliminadas con éxito'));

      // Limpiar caché y preferencias si es necesario
      print('🗑️ AuthProvider: Limpiando caché y preferencias de usuario');

      // Aquí podrías agregar más operaciones de limpieza:
      // - SharedPreferences
      // - Caché de imágenes
      // - Tokens almacenados
      // etc.

      print('✅ AuthProvider: Datos locales eliminados completamente');
    } catch (e) {
      print('💥 AuthProvider: Error durante la limpieza de datos locales: $e');
      // Continuar con el proceso incluso si hay errores en la limpieza local
    }
  }
}
