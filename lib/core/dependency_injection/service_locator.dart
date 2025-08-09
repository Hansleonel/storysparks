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

// Subscription
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

  // Presentation Layer - Page Providers (Factory ✅)
  getIt.registerFactory(() => ProfileProvider(
        getProfileUseCase: getIt<GetProfileUseCase>(),
        getUserStoriesUseCase: getIt<GetUserStoriesUseCase>(),
      ));
  getIt.registerFactory(() => HomeProvider(
        getIt<GetUserNameUseCase>(),
        getIt<AuthRepository>(),
        getIt<GenerateStoryUseCase>(),
        getIt<GetImageDescriptionUseCase>(),
      ));
  getIt.registerFactory(() => SettingsProvider(getIt()));
  getIt.registerFactory(() => SubscriptionProvider());
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
