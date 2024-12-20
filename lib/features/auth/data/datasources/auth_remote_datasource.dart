import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:storysparks/core/constants/api_constants.dart';
import 'package:storysparks/features/auth/data/models/login_request_model.dart';
import 'package:storysparks/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(LoginRequestModel loginRequest);
  Future<UserModel> register(LoginRequestModel registerRequest);
  Future<void> logout();
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(@Named('authDio') this._dio);

  @override
  Future<UserModel> login(LoginRequestModel loginRequest) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: loginRequest.toJson(),
      );

      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw Exception('Failed to login');
    }
  }

  @override
  Future<UserModel> register(LoginRequestModel registerRequest) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: registerRequest.toJson(),
      );

      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw Exception('Failed to register');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      throw Exception('Failed to logout');
    }
  }
}
