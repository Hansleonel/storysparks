import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInWithAppleUseCase
    implements UseCase<AuthResponse, SignInWithAppleParams> {
  final AuthRepository repository;

  SignInWithAppleUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(
      SignInWithAppleParams params) async {
    return await repository.signInWithApple(
      params.idToken,
      params.accessToken,
      givenName: params.givenName,
      familyName: params.familyName,
    );
  }
}

class SignInWithAppleParams extends Equatable {
  final String idToken;
  final String accessToken;
  final String? givenName;
  final String? familyName;

  const SignInWithAppleParams({
    required this.idToken,
    required this.accessToken,
    this.givenName,
    this.familyName,
  });

  @override
  List<Object?> get props => [idToken, accessToken, givenName, familyName];
}
