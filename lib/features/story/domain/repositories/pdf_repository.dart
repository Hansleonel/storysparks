import 'dart:io';
import '../entities/story_pdf.dart';

abstract class PdfRepository {
  Future<File> generatePdf(StoryPdf storyPdf);
  Future<String> savePdfLocally(File pdf, String fileName);
  Future<void> sharePdf(File pdf);
}
