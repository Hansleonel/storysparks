import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/auth/domain/entities/profile.dart';
import 'package:memorysparks/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<Profile, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, Profile>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      username: params.username,
      fullName: params.fullName,
      bio: params.bio,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String username;
  final String? fullName;
  final String? bio;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.username,
    this.fullName,
    this.bio,
  });

  @override
  List<Object?> get props => [email, password, username, fullName, bio];
}
