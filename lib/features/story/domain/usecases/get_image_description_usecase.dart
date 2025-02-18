import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/story_repository.dart';

class GetImageDescriptionUseCase implements UseCase<String, String> {
  final StoryRepository repository;

  GetImageDescriptionUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(String imagePath) async {
    try {
      final description = await repository.getImageDescription(imagePath);
      return Right(description);
    } on Exception catch (e) {
      if (e.toString().contains('file not found')) {
        return Left(
            CacheFailure('The image file was not found. Please try again.'));
      } else if (e.toString().contains('too large')) {
        return Left(
            ServerFailure('The image is too large. Maximum allowed: 20MB'));
      } else if (e.toString().contains('invalid format')) {
        return Left(ServerFailure(
            'The image format is not supported. Use: JPEG, PNG, WEBP, HEIC'));
      }
      return Left(
          ServerFailure('Error al procesar la imagen: ${e.toString()}'));
    }
  }
}
