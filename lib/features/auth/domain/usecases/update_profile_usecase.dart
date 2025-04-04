import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/auth/domain/entities/profile.dart';
import 'package:memorysparks/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<Profile, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Profile>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params.profile);
  }
}

class UpdateProfileParams extends Equatable {
  final Profile profile;

  const UpdateProfileParams({required this.profile});

  @override
  List<Object> get props => [profile];
}
