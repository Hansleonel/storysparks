import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInWithGoogleUseCase
    implements UseCase<AuthResponse, SignInWithGoogleParams> {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(
      SignInWithGoogleParams params) async {
    return await repository.signInWithGoogle(
      params.idToken,
      params.accessToken,
    );
  }
}

class SignInWithGoogleParams extends Equatable {
  final String idToken;
  final String accessToken;

  const SignInWithGoogleParams({
    required this.idToken,
    required this.accessToken,
  });

  @override
  List<Object> get props => [idToken, accessToken];
}
