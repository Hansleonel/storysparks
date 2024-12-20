import 'package:storysparks/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:storysparks/features/auth/data/models/login_request_model.dart';
import 'package:storysparks/features/auth/data/models/user_model.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final loginRequest = LoginRequestModel(
        email: email,
        password: password,
      );
      final user = await _remoteDataSource.login(loginRequest);
      return user;
    } catch (e) {
      throw Exception('Failed to login');
    }
  }

  @override
  Future<UserModel> register(String email, String password) async {
    try {
      final registerRequest = LoginRequestModel(
        email: email,
        password: password,
      );
      final user = await _remoteDataSource.register(registerRequest);
      return user;
    } catch (e) {
      throw Exception('Failed to register');
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _remoteDataSource.logout();
      return true;
    } catch (e) {
      return false;
    }
  }
}
