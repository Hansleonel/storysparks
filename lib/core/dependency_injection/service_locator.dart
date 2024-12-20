import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:storysparks/core/constants/api_constants.dart';
import 'package:storysparks/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:storysparks/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';

import 'service_locator.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
void setupServiceLocator() => getIt.init();

@module
abstract class RegisterModule {
  @Named('authDio')
  @lazySingleton
  Dio get authDio => Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ));

  @lazySingleton
  AuthRepository get authRepository =>
      AuthRepositoryImpl(AuthRemoteDataSourceImpl(authDio));
}
