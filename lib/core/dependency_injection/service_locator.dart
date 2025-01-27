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
import 'package:storysparks/features/story/domain/usecases/update_story_rating_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/continue_story_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storysparks/features/auth/domain/usecases/logout_usecase.dart';
import 'package:storysparks/features/profile/presentation/providers/settings_provider.dart';

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
    () => AuthRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // Story
  getIt.registerLazySingleton<StoryLocalDatasource>(
    () => StoryLocalDatasource(),
  );
  getIt.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(getIt<StoryLocalDatasource>()),
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
  getIt.registerLazySingleton(
      () => ContinueStoryUseCase(getIt<StoryRepository>()));

  // Presentation Layer - Page Providers (Factory ✅)
  getIt.registerFactory(() => ProfileProvider(getIt<GetProfileUseCase>()));
  getIt.registerFactory(
    () => HomeProvider(
      getIt<GetUserNameUseCase>(),
      getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory(() => SettingsProvider(getIt<LogoutUseCase>()));

  // Nota: Los providers globales están en main.dart ℹ️
  // - AuthProvider
  // - LibraryProvider
  // - StoryProvider
}
