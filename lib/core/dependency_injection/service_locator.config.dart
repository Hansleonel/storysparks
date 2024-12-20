// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:storysparks/core/dependency_injection/service_locator.dart'
    as _i68;
import 'package:storysparks/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i609;
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart'
    as _i97;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i97.AuthRepository>(() => registerModule.authRepository);
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.authDio,
      instanceName: 'authDio',
    );
    gh.factory<_i609.AuthRemoteDataSource>(() =>
        _i609.AuthRemoteDataSourceImpl(gh<_i361.Dio>(instanceName: 'authDio')));
    return this;
  }
}

class _$RegisterModule extends _i68.RegisterModule {}
