import 'package:flutter/foundation.dart';
import 'package:storysparks/core/usecases/usecase.dart';
import 'package:storysparks/features/auth/domain/entities/profile.dart';
import 'package:storysparks/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:storysparks/features/story/domain/entities/story.dart';
import 'package:storysparks/features/story/domain/usecases/get_user_stories_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  final GetProfileUseCase _getProfileUseCase;
  final GetUserStoriesUseCase _getUserStoriesUseCase;

  ProfileProvider({
    required GetProfileUseCase getProfileUseCase,
    required GetUserStoriesUseCase getUserStoriesUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _getUserStoriesUseCase = getUserStoriesUseCase {
    debugPrint('🔄 ProfileProvider: Initializing...');
    _loadProfile();
  }

  bool _isLoading = true;
  String? _error;
  Profile? _profile;
  List<Story> _stories = [];
  bool _isLoadingStories = false;
  String? _storiesError;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Profile? get profile => _profile;
  List<Story> get stories => _stories;
  bool get isLoadingStories => _isLoadingStories;
  String? get storiesError => _storiesError;

  String getDisplayName() {
    if (_profile == null) {
      debugPrint('⚠️ ProfileProvider: No profile available for display name');
      return '';
    }
    final displayName =
        _formatDisplayName(_profile!.fullName, _profile!.username);
    debugPrint('👤 ProfileProvider: Display name formatted: $displayName');
    return displayName;
  }

  String _formatDisplayName(String? fullName, String username) {
    debugPrint(
        '🔄 ProfileProvider: Formatting display name - fullName: $fullName, username: $username');
    if (fullName == null || fullName.trim().isEmpty) {
      debugPrint('ℹ️ ProfileProvider: Using username as display name');
      return username;
    }

    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      final formattedName = '${parts[0]} ${parts[1]}';
      debugPrint(
          '✅ ProfileProvider: Using first two parts of full name: $formattedName');
      return formattedName;
    } else {
      debugPrint('✅ ProfileProvider: Using single name: ${parts[0]}');
      return parts[0];
    }
  }

  Future<void> _loadProfile() async {
    try {
      debugPrint('🔄 ProfileProvider: Starting profile load...');
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _getProfileUseCase(NoParams());

      result.fold(
        (failure) {
          debugPrint(
              '❌ ProfileProvider: Error loading profile - ${failure.message}');
          _error = failure.message;
          _profile = null;
        },
        (profile) {
          debugPrint('✅ ProfileProvider: Profile loaded successfully');
          debugPrint(
              '📊 ProfileProvider: Profile data - username: ${profile?.username}, id: ${profile?.id}');
          _profile = profile;
          _error = null;
          if (profile != null) {
            debugPrint(
                '🔄 ProfileProvider: Initiating stories load for user: ${profile.id}');
            _loadUserStories(profile.id);
          } else {
            debugPrint('⚠️ ProfileProvider: No profile data available');
          }
        },
      );
    } catch (e) {
      debugPrint('❌ ProfileProvider: Unexpected error loading profile - $e');
      _error = e.toString();
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('🏁 ProfileProvider: Profile load process completed');
    }
  }

  Future<void> _loadUserStories(String userId) async {
    try {
      debugPrint('🔄 ProfileProvider: Loading stories for user: $userId');
      _isLoadingStories = true;
      _storiesError = null;
      notifyListeners();

      final result = await _getUserStoriesUseCase.execute(userId);
      result.fold(
        (failure) {
          debugPrint('❌ ProfileProvider: Error loading stories - $failure');
          _storiesError = failure.toString();
          _stories = [];
        },
        (stories) {
          debugPrint(
              '✅ ProfileProvider: Stories loaded successfully - Count: ${stories.length}');
          _stories = stories;
          _storiesError = null;
          for (var story in stories) {
            debugPrint(
                '📖 Story ID: ${story.id}, Title: ${story.title}, Rating: ${story.rating}');
          }
        },
      );
    } catch (e) {
      debugPrint('❌ ProfileProvider: Unexpected error loading stories - $e');
      _storiesError = e.toString();
      _stories = [];
    } finally {
      _isLoadingStories = false;
      notifyListeners();
      debugPrint('🏁 ProfileProvider: Stories load process completed');
    }
  }

  Future<void> refreshProfile() async {
    debugPrint('🔄 ProfileProvider: Refreshing profile...');
    await _loadProfile();
  }

  Future<void> refreshStories() async {
    if (_profile != null) {
      debugPrint(
          '🔄 ProfileProvider: Refreshing stories for user: ${_profile!.id}');
      await _loadUserStories(_profile!.id);
    } else {
      debugPrint(
          '⚠️ ProfileProvider: Cannot refresh stories - No profile available');
    }
  }
}
