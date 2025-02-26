import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:storysparks/core/constants/api_constants.dart';
import 'package:storysparks/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:storysparks/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:storysparks/features/auth/domain/usecases/login_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/register_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:storysparks/features/home/domain/usecases/get_user_name_usecase.dart';
import 'package:storysparks/features/home/presentation/providers/home_provider.dart';
import 'package:storysparks/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:storysparks/features/profile/presentation/providers/profile_provider.dart';
import 'package:storysparks/features/story/data/datasources/story_local_datasource.dart';
import 'package:storysparks/features/story/data/repositories/story_repository_impl.dart';
import 'package:storysparks/features/story/domain/repositories/story_repository.dart';
import 'package:storysparks/features/story/domain/usecases/delete_story_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/generate_story_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/get_user_stories_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/save_story_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/update_story_rating_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storysparks/features/auth/domain/usecases/logout_usecase.dart';
import 'package:storysparks/features/profile/presentation/providers/settings_provider.dart';
import 'package:storysparks/features/story/data/services/story_cleanup_service.dart';
import 'package:storysparks/features/story/domain/usecases/update_story_status_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/continue_story_usecase.dart';
import 'package:storysparks/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:storysparks/features/story/domain/usecases/get_image_description_usecase.dart';
import 'package:storysparks/features/story/data/services/image_service.dart';
import 'package:storysparks/features/story/domain/usecases/increment_continuation_count_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/get_story_by_id_usecase.dart';

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
      ));

  // Services
  getIt.registerLazySingleton<StoryCleanupService>(
    () => StoryCleanupService(getIt<StoryRepository>()),
  );

  // Domain Layer - Use Cases (Singleton ✅)
  // Auth
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => SignInWithAppleUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt
      .registerLazySingleton(() => GetUserNameUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetProfileUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));

  // Story
  getIt.registerLazySingleton(
      () => UpdateStoryRatingUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(
      () => DeleteStoryUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(() => SaveStoryUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(
      () => GetUserStoriesUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(
      () => GenerateStoryUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(
      () => UpdateStoryStatusUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(
      () => ContinueStoryUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(
      () => GetImageDescriptionUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(
      () => IncrementContinuationCountUseCase(getIt<StoryRepository>()));
  getIt.registerLazySingleton(
      () => GetStoryByIdUseCase(getIt<StoryRepository>()));

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

  // Nota: Los providers globales están en main.dart ℹ️
  // - AuthProvider
  // - LibraryProvider
  // - StoryProvider
}
