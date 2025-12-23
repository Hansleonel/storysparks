import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core
import 'package:memorysparks/core/constants/api_constants.dart';
import 'package:memorysparks/core/services/share_service.dart';
import 'package:memorysparks/core/services/pdf_letter_service.dart';
import '../data/repositories/locale_repository_impl.dart';
import '../domain/repositories/locale_repository.dart';

// Auth
import 'package:memorysparks/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:memorysparks/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:memorysparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:memorysparks/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/login_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/logout_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/register_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:memorysparks/features/auth/domain/usecases/sign_out_usecase.dart';

// Home
import 'package:memorysparks/features/home/domain/usecases/get_user_name_usecase.dart';
import 'package:memorysparks/features/home/presentation/providers/home_provider.dart';

// Profile
import 'package:memorysparks/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:memorysparks/features/profile/presentation/providers/profile_provider.dart';
import 'package:memorysparks/features/profile/presentation/providers/settings_provider.dart';

// Story
import 'package:memorysparks/features/story/data/datasources/story_local_datasource.dart';
import 'package:memorysparks/features/story/data/repositories/story_repository_impl.dart';
import 'package:memorysparks/features/story/data/services/image_service.dart';
import 'package:memorysparks/features/story/data/services/story_cleanup_service.dart';
import 'package:memorysparks/features/story/domain/repositories/story_repository.dart';
import 'package:memorysparks/features/story/domain/usecases/continue_story_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/delete_all_stories_for_user_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/delete_story_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/generate_story_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/get_image_description_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/get_user_stories_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/save_story_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/share_story_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/update_story_rating_usecase.dart';
import 'package:memorysparks/features/story/domain/usecases/update_story_status_usecase.dart';
import 'package:memorysparks/features/story/presentation/providers/share_provider.dart';

// Audio
import 'package:memorysparks/features/audio/data/datasources/tts_datasource.dart';
import 'package:memorysparks/features/audio/data/datasources/replicate_tts_datasource.dart';
import 'package:memorysparks/features/audio/data/datasources/gemini_tts_datasource.dart';
import 'package:memorysparks/features/audio/data/repositories/audio_repository_impl.dart';
import 'package:memorysparks/features/audio/domain/repositories/audio_repository.dart';
import 'package:memorysparks/features/audio/domain/usecases/generate_story_audio_usecase.dart';

// Subscription
import 'package:memorysparks/features/subscription/data/datasources/revenuecat_datasource.dart';
import 'package:memorysparks/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:memorysparks/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:memorysparks/features/subscription/domain/usecases/check_premium_status_usecase.dart';
import 'package:memorysparks/features/subscription/domain/usecases/get_offerings_usecase.dart';
import 'package:memorysparks/features/subscription/domain/usecases/initialize_revenuecat_usecase.dart';
import 'package:memorysparks/features/subscription/domain/usecases/logout_revenuecat_usecase.dart';
import 'package:memorysparks/features/subscription/domain/usecases/purchase_package_usecase.dart';
import 'package:memorysparks/features/subscription/domain/usecases/restore_purchases_usecase.dart';
import 'package:memorysparks/features/subscription/presentation/providers/subscription_provider.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // External Dependencies (Singleton ✅)
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    )),
  );

  // Data Layer (Singleton ✅)
  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<SupabaseClient>()));
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()));

  // Story
  getIt.registerLazySingleton<StoryLocalDatasource>(
      () => StoryLocalDatasource());
  getIt.registerLazySingleton<ImageService>(() => ImageService());
  getIt.registerLazySingleton<StoryRepository>(() => StoryRepositoryImpl(
        getIt<StoryLocalDatasource>(),
        getIt<ImageService>(),
        getIt<LocaleRepository>(),
      ));

  // Core
  getIt.registerLazySingleton<LocaleRepository>(() => LocaleRepositoryImpl());

  // ═══════════════════════════════════════════════════════════════════════════
  // TTS PROVIDER CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════════════
  // To switch between TTS providers, comment/uncomment the appropriate line:
  //
  // OPTION 1: Replicate TTS (default)
  //   - Returns audio URL, Flutter downloads it
  //   - Requires REPLICATE_API_TOKEN in Supabase secrets
  //
  // OPTION 2: Gemini TTS
  //   - Returns base64 audio data, Flutter decodes it locally
  //   - Requires GEMINI_API_KEY in Supabase secrets
  //   - Supports genre-based narration styling (voice: Algieba)
  //
  // Both providers produce identical local audio files.
  // The AudioRepository automatically detects the format and handles it.
  // ═══════════════════════════════════════════════════════════════════════════

  // OPTION 1: Replicate TTS (ACTIVE) - Comment this line to disable
  getIt.registerLazySingleton<TTSDataSource>(
      () => ReplicateTTSDataSourceImpl(getIt<SupabaseClient>()));

  // OPTION 2: Gemini TTS - Uncomment this line to use Gemini instead
  // getIt.registerLazySingleton<TTSDataSource>(
  //     () => GeminiTTSDataSourceImpl(getIt<SupabaseClient>()));

  getIt.registerLazySingleton<AudioRepository>(
      () => AudioRepositoryImpl(getIt<TTSDataSource>()));

  // Subscription
  getIt.registerLazySingleton<RevenueCatDataSource>(
      () => RevenueCatDataSourceImpl());
  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      revenueCatDataSource: getIt<RevenueCatDataSource>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // Services
  getIt.registerLazySingleton<StoryCleanupService>(
    () => StoryCleanupService(getIt<StoryRepository>()),
  );
  getIt.registerLazySingleton<ShareService>(() => ShareService());
  getIt.registerLazySingleton<PDFLetterService>(() => PDFLetterService());

  // Domain Layer - Use Cases (Singleton ✅)
  // Auth
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => SignInWithAppleUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => SignInWithGoogleUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => DeleteAccountUseCase(getIt<AuthRepository>()));
  getIt
      .registerLazySingleton(() => GetUserNameUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetProfileUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));

  // Story
  getIt.registerLazySingleton(
      () => ContinueStoryUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(
      () => DeleteAllStoriesForUserUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(
      () => DeleteStoryUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(() => GenerateStoryUseCase(
        repository: getIt<StoryRepository>(),
        localeRepository: getIt<LocaleRepository>(),
      ));
  getIt.registerLazySingleton(
      () => GetImageDescriptionUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(
      () => GetUserStoriesUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(() => SaveStoryUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(() => ShareStoryUseCase());
  getIt.registerLazySingleton(
      () => UpdateStoryRatingUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(
      () => UpdateStoryStatusUseCase(getIt<StoryRepository>()));

  // Audio
  getIt.registerLazySingleton(
      () => GenerateStoryAudioUseCase(getIt<AudioRepository>()));

  // Subscription Use Cases
  getIt.registerLazySingleton(
      () => InitializeRevenueCatUseCase(getIt<SubscriptionRepository>()));
  getIt.registerLazySingleton(
      () => LogoutRevenueCatUseCase(getIt<SubscriptionRepository>()));
  getIt.registerLazySingleton(
      () => CheckPremiumStatusUseCase(getIt<SubscriptionRepository>()));
  getIt.registerLazySingleton(
      () => GetOfferingsUseCase(getIt<SubscriptionRepository>()));
  getIt.registerLazySingleton(
      () => PurchasePackageUseCase(getIt<SubscriptionRepository>()));
  getIt.registerLazySingleton(
      () => RestorePurchasesUseCase(getIt<SubscriptionRepository>()));

  // Presentation Layer - Page Providers (Factory ✅)
  getIt.registerFactory(() => ProfileProvider(
        getProfileUseCase: getIt<GetProfileUseCase>(),
        getUserStoriesUseCase: getIt<GetUserStoriesUseCase>(),
      ));
  getIt.registerFactory(() => HomeProvider(
        getIt<GetProfileUseCase>(),
        getIt<AuthRepository>(),
        getIt<GenerateStoryUseCase>(),
        getIt<GetImageDescriptionUseCase>(),
      ));
  getIt.registerFactory(() => SettingsProvider(getIt()));
  getIt.registerFactory(() => SubscriptionProvider(
        initializeRevenueCatUseCase: getIt<InitializeRevenueCatUseCase>(),
        logoutRevenueCatUseCase: getIt<LogoutRevenueCatUseCase>(),
        checkPremiumStatusUseCase: getIt<CheckPremiumStatusUseCase>(),
        getOfferingsUseCase: getIt<GetOfferingsUseCase>(),
        purchasePackageUseCase: getIt<PurchasePackageUseCase>(),
        restorePurchasesUseCase: getIt<RestorePurchasesUseCase>(),
      ));
  getIt.registerFactory(() => ShareProvider(
        shareStoryUseCase: getIt<ShareStoryUseCase>(),
        shareService: getIt<ShareService>(),
        pdfLetterService: getIt<PDFLetterService>(),
      ));

  // Nota: Los providers globales están en main.dart ℹ️
  // - AuthProvider
  // - LibraryProvider
  // - StoryProvider
}
