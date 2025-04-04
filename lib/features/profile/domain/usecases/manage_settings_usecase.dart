import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class ManageSettingsUseCase implements UseCase<Map<String, dynamic>, NoParams> {
  final SettingsRepository repository;

  ManageSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    try {
      final settings = await repository.getSettings();
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateSetting(String key, dynamic value) async {
    try {
      await repository.updateSetting(key, value);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> saveSettings(
      Map<String, dynamic> settings) async {
    try {
      await repository.saveSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
