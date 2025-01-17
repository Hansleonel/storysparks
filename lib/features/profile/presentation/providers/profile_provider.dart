import 'package:flutter/foundation.dart';
import 'package:storysparks/core/usecases/usecase.dart';
import 'package:storysparks/features/auth/domain/entities/profile.dart';
import 'package:storysparks/features/profile/domain/usecases/get_profile_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  final GetProfileUseCase _getProfileUseCase;

  ProfileProvider(this._getProfileUseCase) {
    _loadProfile();
  }

  bool _isLoading = true;
  String? _error;
  Profile? _profile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Profile? get profile => _profile;

  String getDisplayName() {
    if (_profile == null) return '';

    return _formatDisplayName(_profile!.fullName, _profile!.username);
  }

  String _formatDisplayName(String? fullName, String username) {
    if (fullName == null || fullName.trim().isEmpty) {
      return username;
    }

    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      // Si tiene dos o más partes, tomamos las dos primeras
      return '${parts[0]} ${parts[1]}';
    } else {
      // Si solo tiene una parte (un nombre), lo devolvemos tal cual
      return parts[0];
    }
  }

  Future<void> _loadProfile() async {
    try {
      debugPrint('🔍 ProfileProvider: Loading profile...');
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _getProfileUseCase(NoParams());

      result.fold(
        (failure) {
          debugPrint('❌ Error loading profile: ${failure.message}');
          _error = failure.message;
          _profile = null;
        },
        (profile) {
          debugPrint('✅ Profile loaded successfully: ${profile?.username}');
          _profile = profile;
          _error = null;
        },
      );
    } catch (e) {
      debugPrint('❌ Unexpected error in ProfileProvider: $e');
      _error = e.toString();
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    await _loadProfile();
  }
}
