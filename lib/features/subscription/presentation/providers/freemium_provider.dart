import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:memorysparks/features/subscription/data/datasources/freemium_local_datasource.dart';
import 'package:memorysparks/features/subscription/domain/usecases/check_story_quota_usecase.dart';
import 'package:memorysparks/features/subscription/presentation/providers/subscription_provider.dart';

/// Provider that combines premium status with freemium quotas
/// to determine what features a user can access.
class FreemiumProvider extends ChangeNotifier {
  final SubscriptionProvider subscriptionProvider;
  final CheckStoryQuotaUseCase checkStoryQuotaUseCase;

  FreemiumProvider({
    required this.subscriptionProvider,
    required this.checkStoryQuotaUseCase,
  }) {
    // Listen to subscription changes
    subscriptionProvider.addListener(_onSubscriptionChanged);
  }

  String? _userId;
  StoryQuotaInfo? _quotaInfo;
  bool _isLoading = false;

  // Getters
  bool get isPremium => subscriptionProvider.isPremium;
  bool get isLoading => _isLoading;
  StoryQuotaInfo? get quotaInfo => _quotaInfo;
  int get savedStoryCount => _quotaInfo?.savedCount ?? 0;
  int get remainingStories => _quotaInfo?.remaining ?? FreemiumLocalDatasource.maxFreeStories;
  int get maxFreeStories => FreemiumLocalDatasource.maxFreeStories;

  /// Initialize with user ID
  Future<void> initialize(String userId) async {
    _userId = userId;
    
    // Ensure premium status is up to date before checking quotas
    log('🔄 FreemiumProvider: Refreshing premium status for user $userId');
    await subscriptionProvider.checkPremiumStatus();
    
    // Now refresh quota
    await refreshQuota();
    
    // Force a notification to update UI with current premium status
    log('✅ FreemiumProvider: Initialized for user $userId - isPremium: $isPremium');
    notifyListeners();
  }

  /// Refresh the quota information
  Future<void> refreshQuota() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    final result = await checkStoryQuotaUseCase(
      CheckStoryQuotaParams(userId: _userId!),
    );

    result.fold(
      (failure) {
        log('❌ FreemiumProvider: Error al obtener cuota: ${failure.toString()}');
        _quotaInfo = null;
      },
      (quotaInfo) {
        log('✅ FreemiumProvider: Cuota actualizada - ${quotaInfo.savedCount}/${quotaInfo.maxFree}');
        _quotaInfo = quotaInfo;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Check if user can generate/save a new story
  /// Premium users: always true
  /// Free users: true if they have remaining slots
  bool canGenerateStory() {
    if (isPremium) return true;
    return _quotaInfo?.canSaveMore ?? true;
  }

  /// Check if user can continue a story
  /// Only available for premium users
  bool canContinueStory() {
    return isPremium;
  }

  /// Check if user can use audio narration
  /// Only available for premium users
  bool canUseAudio() {
    return isPremium;
  }

  /// Called when a story is saved - refresh quota
  Future<void> onStorySaved() async {
    await refreshQuota();
  }

  /// Called when a story is deleted - refresh quota
  Future<void> onStoryDeleted() async {
    await refreshQuota();
  }

  void _onSubscriptionChanged() {
    // When subscription status changes, notify listeners
    log('🔄 FreemiumProvider: Subscription status changed - isPremium: $isPremium');
    notifyListeners();
  }

  @override
  void dispose() {
    subscriptionProvider.removeListener(_onSubscriptionChanged);
    super.dispose();
  }
}

