import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:storysparks/core/error/failures.dart';
import 'package:storysparks/core/usecases/usecase.dart';
import 'package:storysparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInWithAppleUseCase
    implements UseCase<AuthResponse, SignInWithAppleParams> {
  final AuthRepository repository;

  SignInWithAppleUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(
      SignInWithAppleParams params) async {
    return await repository.signInWithApple(params.idToken, params.accessToken);
  }
}

class SignInWithAppleParams extends Equatable {
  final String idToken;
  final String accessToken;

  const SignInWithAppleParams({
    required this.idToken,
    required this.accessToken,
  });

  @override
  List<Object> get props => [idToken, accessToken];
}
