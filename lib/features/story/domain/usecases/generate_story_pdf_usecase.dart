import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:storysparks/core/error/failures.dart';
import '../entities/story.dart';
import '../entities/story_pdf.dart';
import '../repositories/pdf_repository.dart';
import 'package:storysparks/core/constants/pdf_constants.dart';
import 'package:storysparks/core/utils/cover_image_helper.dart';
import 'package:intl/intl.dart';

class GenerateStoryPdfUseCase {
  final PdfRepository _repository;

  GenerateStoryPdfUseCase(this._repository);

  Future<Either<Failure, File>> execute(Story story, String userName) async {
    try {
      debugPrint('📄 GenerateStoryPdfUseCase: Starting PDF generation');

      final storyPdf = StoryPdf(
        title: PdfConstants.genreTitles[story.genre] ?? 'My Story',
        content: story.content,
        genre: story.genre,
        authorName: userName,
        generatedDate: DateTime.now(),
        coverImagePath: CoverImageHelper.getCoverImage(story.genre),
      );

      debugPrint('📄 GenerateStoryPdfUseCase: Creating PDF file');
      final pdfFile = await _repository.generatePdf(storyPdf);

      final fileName =
          'story_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      debugPrint('📄 GenerateStoryPdfUseCase: Saving PDF as $fileName');

      await _repository.savePdfLocally(pdfFile, fileName);

      debugPrint('✅ GenerateStoryPdfUseCase: PDF generated successfully');
      return Right(pdfFile);
    } catch (e) {
      debugPrint('❌ GenerateStoryPdfUseCase: Error generating PDF - $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
