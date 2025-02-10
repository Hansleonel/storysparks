import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/story_pdf.dart';
import '../../domain/repositories/pdf_repository.dart';
import 'package:storysparks/core/constants/pdf_constants.dart';

class PdfRepositoryImpl implements PdfRepository {
  @override
  Future<File> generatePdf(StoryPdf storyPdf) async {
    debugPrint('📄 PdfRepository: Starting PDF generation');
    debugPrint('🖼️ Loading image from path: ${storyPdf.coverImagePath}');

    final pdf = pw.Document();

    // Cargar las fuentes
    final pacificoFont =
        await rootBundle.load('assets/fonts/Pacifico-Regular.ttf');
    final loraFont = await rootBundle.load('assets/fonts/Lora-Regular.ttf');

    final ttfPacifico = pw.Font.ttf(pacificoFont);
    final ttfLora = pw.Font.ttf(loraFont);

    // Cargar la imagen de portada
    final imageBytes = await rootBundle.load(storyPdf.coverImagePath);
    final coverImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

    // Comenzamos a construir el PDF con múltiples páginas
    pdf.addPage(
      pw.MultiPage(
        maxPages: 50, // Límite máximo de páginas
        pageTheme: pw.PageTheme(
          // Formato A4 con fondo personalizado
          pageFormat: PdfPageFormat.a4,
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfConstants.bgColor,
              ),
            ),
          ),
          // Márgenes globales del documento
          margin: const pw.EdgeInsets.symmetric(
            horizontal: PdfConstants.marginHorizontal,
            vertical: PdfConstants.marginTop,
          ),
          theme: pw.ThemeData.withFont(
            base: ttfLora,
            italic: ttfPacifico,
          ),
        ),
        // HEADER: Solo en primera página - Título e imagen
        header: (context) {
          if (context.pageNumber == 1) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(
                  bottom: PdfConstants.spacingAfterHeader),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Título (lado izquierdo)
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.only(
                          right: PdfConstants.headerSpacing),
                      child: pw.Text(
                        storyPdf.title,
                        style: pw.TextStyle(
                          font: ttfPacifico,
                          fontSize: PdfConstants.titleFontSize,
                          color: PdfConstants.textColor,
                          height: PdfConstants.titleLineHeight,
                        ),
                      ),
                    ),
                  ),
                  // Imagen (lado derecho)
                  pw.Expanded(
                    flex: 2,
                    child: pw.ClipRRect(
                      horizontalRadius: 10,
                      verticalRadius: 10,
                      child: pw.Image(
                        coverImage,
                        fit: pw.BoxFit.cover,
                        height: PdfConstants.imageSize,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return pw.Container();
        },
        // FOOTER: Solo en última página - Firma y fecha
        footer: (context) {
          if (context.pageNumber == context.pagesCount) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(
                  top: PdfConstants.spacingBeforeSignature),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  // Mensaje de despedida en fuente decorativa
                  pw.Text(
                    'I love you with all\nmy heart,',
                    style: pw.TextStyle(
                      font: ttfPacifico,
                      fontSize: PdfConstants.signatureFontSize,
                      color: PdfConstants.textColor,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  // Nombre del autor en fuente base
                  pw.Text(
                    storyPdf.authorName,
                    style: pw.TextStyle(
                      font: ttfLora,
                      fontSize: PdfConstants.signatureFontSize,
                      color: PdfConstants.textColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  // Decoración "xoxo" en color de acento
                  pw.Text(
                    'xoxo',
                    style: pw.TextStyle(
                      font: ttfPacifico,
                      fontSize: PdfConstants.signatureFontSize,
                      color: PdfConstants.accentColor,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  // Fecha en color más claro
                  pw.Text(
                    DateFormat('MMMM dd, yyyy').format(storyPdf.generatedDate),
                    style: pw.TextStyle(
                      font: ttfLora,
                      fontSize: PdfConstants.contentFontSize,
                      color: PdfConstants.textColor.shade(50),
                    ),
                  ),
                ],
              ),
            );
          }
          return pw.Container();
        },
        // CONTENIDO PRINCIPAL: Historia con texto justificado
        build: (context) => [
          pw.Paragraph(
            margin: const pw.EdgeInsets.all(0),
            text: storyPdf.content,
            style: pw.TextStyle(
              fontSize: PdfConstants.contentFontSize,
              height: PdfConstants
                  .contentLineHeight, // Controla el espacio entre líneas
              color: PdfConstants.textColor,
            ),
            textAlign: pw.TextAlign.justify, // Alineación justificada del texto
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/temp_story.pdf');
    await file.writeAsBytes(await pdf.save());

    debugPrint('✅ PdfRepository: PDF generated successfully');
    return file;
  }

  @override
  Future<String> savePdfLocally(File pdf, String fileName) async {
    debugPrint('📄 PdfRepository: Saving PDF locally');
    final directory = await getApplicationDocumentsDirectory();
    final savedFile = await pdf.copy('${directory.path}/$fileName');
    debugPrint('✅ PdfRepository: PDF saved at ${savedFile.path}');
    return savedFile.path;
  }

  @override
  Future<void> sharePdf(File pdf) async {
    debugPrint('📄 PdfRepository: Sharing PDF');
    await Share.shareXFiles([XFile(pdf.path)],
        text: 'My Story from StorySparks');
    debugPrint('✅ PdfRepository: PDF shared successfully');
  }
}
