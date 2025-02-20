import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

class ImageService {
  static const int maxSizeInBytes = 6 * 1024 * 1024; // 6MB
  static const double coverAspectRatio = 2 / 3;
  static const int maxWidth = 1080;
  static const int maxHeight = 1620; // maxWidth * 3/2 for 2:3 aspect ratio

  Future<String?> processAndSaveStoryImage(String originalImagePath) async {
    try {
      final File originalFile = File(originalImagePath);
      if (!await originalFile.exists()) {
        debugPrint('❌ ImageService: Archivo original no encontrado');
        return null;
      }

      // Verificar tamaño
      final fileSize = await originalFile.length();
      if (fileSize > maxSizeInBytes) {
        debugPrint(
            '❌ ImageService: Imagen demasiado grande: ${fileSize / 1024 / 1024}MB');
        return null;
      }

      // Crear directorio si no existe
      final appDir = await getApplicationDocumentsDirectory();
      final storiesDir = Directory('${appDir.path}/story_images');
      if (!await storiesDir.exists()) {
        await storiesDir.create(recursive: true);
      }

      // Generar nombre único
      final String fileName = const Uuid().v4() + extension(originalImagePath);
      final String destinationPath = join(storiesDir.path, fileName);

      // Procesar imagen
      final bytes = await originalFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        debugPrint('❌ ImageService: No se pudo decodificar la imagen');
        return null;
      }

      // Redimensionar manteniendo aspect ratio
      var processedImage = image;
      if (image.width > maxWidth || image.height > maxHeight) {
        processedImage = img.copyResize(
          image,
          width: maxWidth,
          height: maxHeight,
          maintainAspect: true,
        );
      }

      // Comprimir y guardar
      final processedBytes = img.encodeJpg(processedImage, quality: 85);
      await File(destinationPath).writeAsBytes(processedBytes);

      debugPrint(
          '✅ ImageService: Imagen procesada y guardada en: $destinationPath');
      return destinationPath;
    } catch (e) {
      debugPrint('❌ ImageService: Error procesando imagen: $e');
      return null;
    }
  }

  Future<void> deleteStoryImage(String? imagePath) async {
    if (imagePath == null) return;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ ImageService: Imagen eliminada: $imagePath');
      }
    } catch (e) {
      debugPrint('❌ ImageService: Error eliminando imagen: $e');
    }
  }
}
