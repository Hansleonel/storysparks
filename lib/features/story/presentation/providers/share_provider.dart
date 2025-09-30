import 'package:flutter/foundation.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';
import 'package:memorysparks/features/story/domain/usecases/share_story_usecase.dart';
import 'package:memorysparks/core/services/share_service.dart';
import 'package:memorysparks/core/services/pdf_letter_service.dart';
import 'package:memorysparks/l10n/app_localizations.dart';

class ShareProvider extends ChangeNotifier {
  final ShareStoryUseCase _shareStoryUseCase;
  final ShareService _shareService;
  final PDFLetterService _pdfLetterService;

  ShareProvider({
    required ShareStoryUseCase shareStoryUseCase,
    required ShareService shareService,
    required PDFLetterService pdfLetterService,
  })  : _shareStoryUseCase = shareStoryUseCase,
        _shareService = shareService,
        _pdfLetterService = pdfLetterService;

  bool _isSharing = false;
  String? _error;

  bool get isSharing => _isSharing;
  String? get error => _error;

  /// Comparte una historia con formato simple
  Future<bool> shareSimple(
      Story story, String appName, AppLocalizations l10n) async {
    return _executeShare(() {
      final translations = _createTranslations(l10n);
      final text =
          _shareStoryUseCase.executeSimple(story, appName, translations);
      return _shareService.shareText(text, subject: story.title);
    });
  }

  /// Comparte una historia con formato elegante (DEPRECATED - usar sharePDF)
  Future<bool> shareStyled(
      Story story, String appName, AppLocalizations l10n) async {
    return _executeShare(() {
      final translations = _createTranslations(l10n);
      final text =
          _shareStoryUseCase.executeStyled(story, appName, translations);
      return _shareService.shareText(text, subject: story.title);
    });
  }

  /// Comparte una historia como carta PDF hermosa
  Future<bool> sharePDF(
      Story story, String appName, AppLocalizations l10n) async {
    return _executeShare(() async {
      debugPrint('📄 ShareProvider: Generando carta PDF hermosa...');

      // Crear traducciones para el PDF
      final pdfTranslations = PDFTranslations(
        personalStory: l10n.pdfPersonalStory,
        generatedWith: l10n.pdfGeneratedWith,
        pageNumber: (pageNum) => l10n.pdfPageNumber(pageNum),
      );

      // Generar el PDF
      final pdfPath = await _pdfLetterService.generateStoryLetter(
        story: story,
        translations: pdfTranslations,
      );

      debugPrint('✅ ShareProvider: PDF generado en: $pdfPath');

      // Compartir el PDF
      await _shareService.sharePDF(
        pdfPath,
        description: '📚 ${story.title}\n\n✨ Generado con $appName',
        subject: story.title,
      );

      debugPrint('✅ ShareProvider: PDF compartido exitosamente');
    });
  }

  /// Crea el objeto de traducciones
  ShareTranslations _createTranslations(AppLocalizations l10n) {
    return ShareTranslations(
      genre: l10n.shareGenre,
      generatedWith: l10n.shareGeneratedWith,
      story: l10n.story,
      details: l10n.shareDetails,
      rating: l10n.shareRating,
      generatedWithAI: l10n.shareGeneratedWithAI,
      downloadApp: l10n.shareDownloadApp,
      continues: l10n.shareContinues,
    );
  }

  /// Ejecuta la operación de compartir con manejo de estado
  Future<bool> _executeShare(Future<void> Function() shareOperation) async {
    try {
      _setLoading(true);
      _clearError();

      await shareOperation();
      return true;
    } catch (e) {
      _setError('Share error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isSharing = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
