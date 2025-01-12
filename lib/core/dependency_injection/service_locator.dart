import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:storysparks/core/constants/api_constants.dart';
import 'package:storysparks/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:storysparks/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:storysparks/features/auth/domain/usecases/login_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import 'package:storysparks/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:storysparks/features/home/domain/usecases/get_user_name_usecase.dart';
import 'package:storysparks/features/story/data/datasources/story_local_datasource.dart';
import 'package:storysparks/features/story/data/repositories/story_repository_impl.dart';
import 'package:storysparks/features/story/domain/repositories/story_repository.dart';
import 'package:storysparks/features/story/domain/usecases/delete_story_usecase.dart';
import 'package:storysparks/features/story/domain/usecases/update_story_rating_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // External
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Network
  getIt.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    )),
  );

  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // Auth Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
      () => SignInWithAppleUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt<AuthRepository>()));
  getIt
      .registerLazySingleton(() => GetUserNameUseCase(getIt<AuthRepository>()));

  // Story
  getIt.registerLazySingleton<StoryLocalDatasource>(
    () => StoryLocalDatasource(),
  );

  getIt.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(getIt<StoryLocalDatasource>()),
  );

  // Story Use Cases
  getIt.registerLazySingleton(
    () => UpdateStoryRatingUseCase(getIt<StoryRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteStoryUseCase(getIt<StoryRepository>()),
  );
}
