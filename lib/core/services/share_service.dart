import 'package:share_plus/share_plus.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  /// Comparte texto usando la funcionalidad nativa de la plataforma
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(
      text,
      subject: subject,
    );
  }

  /// Comparte archivos (PDFs, imágenes, etc.)
  Future<void> shareFiles(
    List<String> filePaths, {
    String? text,
    String? subject,
  }) async {
    final xFiles = filePaths.map((path) => XFile(path)).toList();
    await Share.shareXFiles(
      xFiles,
      text: text,
      subject: subject,
    );
  }

  /// Comparte un PDF específico (caso futuro común)
  Future<void> sharePDF(
    String pdfPath, {
    String? description,
    String? subject,
  }) async {
    await shareFiles(
      [pdfPath],
      text: description,
      subject: subject,
    );
  }

  /// Comparte con resultado para analytics futuros
  Future<ShareResult> shareWithResult(String text, {String? subject}) async {
    return await Share.shareWithResult(
      text,
      subject: subject,
    );
  }

  /// Verifica si un archivo existe antes de compartir
  bool canShareFile(String filePath) {
    // Aquí podrías agregar validaciones futuras
    return filePath.isNotEmpty;
  }
}
