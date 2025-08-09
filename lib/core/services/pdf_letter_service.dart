import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:memorysparks/features/story/domain/entities/story.dart';
import 'package:memorysparks/features/story/domain/entities/story_params.dart';
import 'package:memorysparks/core/utils/cover_image_helper.dart';

/// Configuración de traducciones para PDFs
class PDFTranslations {
  final String personalStory;
  final String generatedWith;
  final String Function(int) pageNumber;

  const PDFTranslations({
    required this.personalStory,
    required this.generatedWith,
    required this.pageNumber,
  });
}

/// Servicio para generar cartas PDF hermosas y elegantes
class PDFLetterService {
  static final PDFLetterService _instance = PDFLetterService._internal();
  factory PDFLetterService() => _instance;
  PDFLetterService._internal();

  // Cache para fuentes y recursos
  Map<String, pw.Font> _fontCache = {};
  pw.ImageProvider? _logoImage;
  Map<String, pw.ImageProvider> _genreImages = {};

  /// Genera una carta PDF hermosa con la historia
  Future<String> generateStoryLetter({
    required Story story,
    required PDFTranslations translations,
    StoryParams? originalParams,
    String? customImagePath,
  }) async {
    final pdf = pw.Document(
      title: story.title,
      author: 'Memory Sparks',
      creator: 'Memory Sparks App',
      subject: 'Historia Personal - ${story.genre}',
    );

    // Cargar recursos necesarios
    await _loadResources(story.genre);

    // Obtener tema basado en el género
    final theme = _getThemeForGenre(story.genre);

    // Procesar el contenido de la historia para paginación
    final storyParagraphs = _processStoryContent(story.content);

    // Generar páginas
    await _generatePages(
        pdf, story, theme, storyParagraphs, translations, originalParams);

    // Guardar archivo
    final outputDir = await getTemporaryDirectory();
    final fileName =
        'carta_${story.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${outputDir.path}/$fileName');

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// Carga todos los recursos necesarios (fuentes, logo, decoraciones)
  Future<void> _loadResources(String genre) async {
    try {
      // Cargar fuentes personalizadas
      if (!_fontCache.containsKey('playfair')) {
        final playfairData =
            await rootBundle.load('assets/fonts/PlayfairDisplay-Bold.ttf');
        _fontCache['playfair'] = pw.Font.ttf(playfairData);
      }

      if (!_fontCache.containsKey('urbanist')) {
        final urbanistData =
            await rootBundle.load('assets/fonts/Urbanist-Regular.ttf');
        _fontCache['urbanist'] = pw.Font.ttf(urbanistData);
      }

      if (!_fontCache.containsKey('urbanist_medium')) {
        final urbanistMediumData =
            await rootBundle.load('assets/fonts/Urbanist-Medium.ttf');
        _fontCache['urbanist_medium'] = pw.Font.ttf(urbanistMediumData);
      }

      // Cargar logo si no está en cache
      if (_logoImage == null) {
        try {
          // Intentar cargar el logo de Memory Sparks
          final logoData =
              await rootBundle.load('assets/icons/app_icon_adaptive.png');
          _logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
        } catch (e) {
          try {
            // Fallback a una imagen existente decorativa
            final logoData =
                await rootBundle.load('assets/images/romantic.png');
            _logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
          } catch (e2) {
            debugPrint('⚠️ Logo no encontrado, usando placeholder');
          }
        }
      }

      // Cargar imagen del género si no está en cache
      await _loadGenreImage(genre);
    } catch (e) {
      debugPrint('❌ Error cargando recursos PDF: $e');
    }
  }

  /// Carga la imagen del género específico
  Future<void> _loadGenreImage(String genre) async {
    final genreKey = genre.toLowerCase();

    if (!_genreImages.containsKey(genreKey)) {
      try {
        final imagePath = CoverImageHelper.getCoverImage(genre);
        final imageData = await rootBundle.load(imagePath);
        _genreImages[genreKey] = pw.MemoryImage(imageData.buffer.asUint8List());
        debugPrint('✅ Imagen del género $genre cargada: $imagePath');
      } catch (e) {
        debugPrint('⚠️ Error cargando imagen del género $genre: $e');
      }
    }
  }

  /// Genera todas las páginas del PDF
  Future<void> _generatePages(
    pw.Document pdf,
    Story story,
    PDFLetterTheme theme,
    List<String> paragraphs,
    PDFTranslations translations,
    StoryParams? originalParams,
  ) async {
    const maxParagraphsPerPage = 15; // Aproximadamente
    final totalPages = (paragraphs.length / maxParagraphsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final isFirstPage = pageIndex == 0;
      final isLastPage = pageIndex == totalPages - 1;

      final startIdx = pageIndex * maxParagraphsPerPage;
      final endIdx =
          (startIdx + maxParagraphsPerPage).clamp(0, paragraphs.length);
      final pageParagraphs = paragraphs.sublist(startIdx, endIdx);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          theme: pw.ThemeData.withFont(
            base: _fontCache['urbanist'],
            bold: _fontCache['urbanist_medium'],
          ),
          header: isFirstPage ? (context) => _buildHeader(story, theme) : null,
          footer: (context) =>
              _buildFooter(context, theme, translations, isLastPage),
          build: (context) {
            if (isFirstPage) {
              return [
                _buildTitle(story, theme, translations),
                pw.SizedBox(height: 30),
                ..._buildStoryContent(pageParagraphs, theme),
              ];
            } else {
              return _buildStoryContent(pageParagraphs, theme);
            }
          },
        ),
      );
    }
  }

  /// Construye el header elegante de la primera página
  pw.Widget _buildHeader(Story story, PDFLetterTheme theme) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey300,
            width: 1,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Logo y nombre
          pw.Row(
            children: [
              if (_logoImage != null) ...[
                pw.Container(
                  width: 32,
                  height: 32,
                  child: pw.Image(_logoImage!),
                ),
                pw.SizedBox(width: 12),
              ],
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Memory Sparks',
                    style: pw.TextStyle(
                      font: _fontCache['playfair'],
                      fontSize: 18,
                      color: theme.primaryColor,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Historias que nacen del corazón',
                    style: pw.TextStyle(
                      font: _fontCache['urbanist'],
                      fontSize: 9,
                      color: theme.textSecondary,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Fecha y género
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                _formatDate(story.createdAt),
                style: pw.TextStyle(
                  font: _fontCache['urbanist'],
                  fontSize: 10,
                  color: theme.textSecondary,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(
                    color: theme.accentColor,
                    width: 0.5,
                  ),
                ),
                child: pw.Text(
                  story.genre,
                  style: pw.TextStyle(
                    font: _fontCache['urbanist_medium'],
                    fontSize: 8,
                    color: theme.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye el título hermoso de la historia
  pw.Widget _buildTitle(
      Story story, PDFLetterTheme theme, PDFTranslations translations) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Decoración superior
          _buildDecorativeLine(theme),
          pw.SizedBox(height: 20),

          // Título principal
          pw.Text(
            story.title,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              font: _fontCache['playfair'],
              fontSize: 24,
              color: theme.primaryColor,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),

          pw.SizedBox(height: 16),

          // Imagen del género
          _buildGenreImage(story.genre, theme),

          pw.SizedBox(height: 16),

          // Subtítulo centrado limpio
          pw.Text(
            translations.personalStory,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              font: _fontCache['urbanist'],
              fontSize: 12,
              color: theme.textSecondary,
              fontStyle: pw.FontStyle.italic,
            ),
          ),

          pw.SizedBox(height: 8),

          // Rating por separado y centrado
          _buildStarRating(story.rating, theme),

          pw.SizedBox(height: 20),

          // Decoración inferior
          _buildDecorativeLine(theme),
        ],
      ),
    );
  }

  /// Construye la imagen del género de manera elegante
  pw.Widget _buildGenreImage(String genre, PDFLetterTheme theme) {
    final genreKey = genre.toLowerCase();
    final genreImage = _genreImages[genreKey];

    if (genreImage == null) {
      // Si no hay imagen, mostrar un placeholder elegante
      return pw.Container(
        width: 120,
        height: 80,
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(
            color: theme.accentColor,
            width: 1,
          ),
        ),
        child: pw.Center(
          child: pw.Text(
            genre,
            style: pw.TextStyle(
              font: _fontCache['urbanist_medium'],
              fontSize: 12,
              color: theme.accentColor,
            ),
          ),
        ),
      );
    }

    return pw.Container(
      width: 120,
      height: 80,
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(12),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColors.grey300,
            blurRadius: 8,
            offset: const PdfPoint(0, 4),
          ),
        ],
      ),
      child: pw.ClipRRect(
        horizontalRadius: 12,
        verticalRadius: 12,
        child: pw.Image(
          genreImage,
          fit: pw.BoxFit.cover,
        ),
      ),
    );
  }

  /// Construye el contenido de la historia con párrafos hermosos
  List<pw.Widget> _buildStoryContent(
      List<String> paragraphs, PDFLetterTheme theme) {
    return paragraphs.map((paragraph) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 16),
        child: pw.Text(
          paragraph,
          textAlign: pw.TextAlign.justify,
          style: pw.TextStyle(
            font: _fontCache['urbanist'],
            fontSize: 11,
            color: theme.textPrimary,
            height: 1.6,
            letterSpacing: 0.3,
          ),
        ),
      );
    }).toList();
  }

  /// Construye el footer elegante
  pw.Widget _buildFooter(pw.Context context, PDFLetterTheme theme,
      PDFTranslations translations, bool isLastPage) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 15),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: PdfColors.grey300,
            width: 0.5,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Marca de agua
          pw.Text(
            translations.generatedWith,
            style: pw.TextStyle(
              font: _fontCache['urbanist'],
              fontSize: 8,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          // Número de página
          if (!isLastPage || context.pageNumber > 1)
            pw.Text(
              translations.pageNumber(context.pageNumber),
              style: pw.TextStyle(
                font: _fontCache['urbanist'],
                fontSize: 8,
                color: theme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  /// Construye una línea decorativa elegante
  pw.Widget _buildDecorativeLine(PDFLetterTheme theme) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Container(
          width: 40,
          height: 1,
          color: theme.accentColor,
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          '✦',
          style: pw.TextStyle(
            color: theme.accentColor,
            fontSize: 12,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Container(
          width: 40,
          height: 1,
          color: theme.accentColor,
        ),
      ],
    );
  }

  /// Construye las estrellas de rating
  pw.Widget _buildStarRating(double rating, PDFLetterTheme theme) {
    final stars = <pw.Widget>[];
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(pw.Text('*',
            style: pw.TextStyle(color: theme.accentColor, fontSize: 10)));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(pw.Text('*',
            style: pw.TextStyle(color: theme.accentColor, fontSize: 10)));
      } else {
        stars.add(pw.Text('·',
            style: pw.TextStyle(color: PdfColors.grey400, fontSize: 10)));
      }
    }

    return pw.Row(children: stars);
  }

  /// Procesa el contenido de la historia en párrafos
  List<String> _processStoryContent(String content) {
    return content
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();
  }

  /// Obtiene el tema visual según el género
  PDFLetterTheme _getThemeForGenre(String genre) {
    switch (genre.toLowerCase()) {
      case 'romance':
        return const PDFLetterTheme(
          primaryColor: PdfColor.fromInt(0xFF8B5A6B),
          accentColor: PdfColor.fromInt(0xFFD4A5B3),
          textPrimary: PdfColor.fromInt(0xFF2C2C2C),
          textSecondary: PdfColor.fromInt(0xFF666666),
        );
      case 'aventura':
        return const PDFLetterTheme(
          primaryColor: PdfColor.fromInt(0xFF2E5A87),
          accentColor: PdfColor.fromInt(0xFF4A90C2),
          textPrimary: PdfColor.fromInt(0xFF2C2C2C),
          textSecondary: PdfColor.fromInt(0xFF666666),
        );
      case 'misterio':
        return const PDFLetterTheme(
          primaryColor: PdfColor.fromInt(0xFF4A4A4A),
          accentColor: PdfColor.fromInt(0xFF8B6914),
          textPrimary: PdfColor.fromInt(0xFF2C2C2C),
          textSecondary: PdfColor.fromInt(0xFF666666),
        );
      case 'fantasía':
        return const PDFLetterTheme(
          primaryColor: PdfColor.fromInt(0xFF6B46C1),
          accentColor: PdfColor.fromInt(0xFF9CA3AF),
          textPrimary: PdfColor.fromInt(0xFF2C2C2C),
          textSecondary: PdfColor.fromInt(0xFF666666),
        );
      default:
        return const PDFLetterTheme(
          primaryColor: PdfColor.fromInt(0xFF2563EB),
          accentColor: PdfColor.fromInt(0xFF60A5FA),
          textPrimary: PdfColor.fromInt(0xFF2C2C2C),
          textSecondary: PdfColor.fromInt(0xFF666666),
        );
    }
  }

  /// Formatea la fecha de manera elegante
  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

/// Configuración de tema visual para el PDF
class PDFLetterTheme {
  final PdfColor primaryColor;
  final PdfColor accentColor;
  final PdfColor textPrimary;
  final PdfColor textSecondary;

  const PDFLetterTheme({
    required this.primaryColor,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
  });
}
