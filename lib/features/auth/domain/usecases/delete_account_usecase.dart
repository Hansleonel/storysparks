import 'package:dartz/dartz.dart';
import 'package:memorysparks/core/error/failures.dart';
import 'package:memorysparks/core/usecases/usecase.dart';
import 'package:memorysparks/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccountUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  DeleteAccountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    print('🧩 DeleteAccountUseCase: Ejecutando caso de uso');
    print(
        '⏱️ DeleteAccountUseCase: Hora de inicio: ${DateTime.now().toIso8601String()}');

    try {
      print('⏳ DeleteAccountUseCase: Llamando al repositorio');
      final result = await repository.deleteAccount();

      result.fold((failure) {
        print('❌ DeleteAccountUseCase: Error: ${failure.message}');
        print('🔍 DeleteAccountUseCase: Tipo de error: ${failure.runtimeType}');
      }, (_) {
        print('✅ DeleteAccountUseCase: Completado exitosamente');
      });

      print(
          '⏱️ DeleteAccountUseCase: Hora de finalización: ${DateTime.now().toIso8601String()}');
      return result;
    } catch (e) {
      print('💥 DeleteAccountUseCase: Excepción no controlada: $e');
      print(
          '⏱️ DeleteAccountUseCase: Hora de error: ${DateTime.now().toIso8601String()}');
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}
