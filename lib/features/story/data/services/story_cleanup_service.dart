import 'package:flutter/foundation.dart';
import '../../domain/repositories/story_repository.dart';

class StoryCleanupService {
  final StoryRepository _repository;
  DateTime? _lastCleanupTime;

  StoryCleanupService(this._repository);

  Future<void> checkAndCleanup() async {
    // Solo ejecutar la limpieza si no se ha ejecutado en la última hora
    // Esto evita múltiples limpiezas innecesarias si el usuario navega frecuentemente
    final now = DateTime.now();
    if (_lastCleanupTime == null ||
        now.difference(_lastCleanupTime!) > const Duration(hours: 1)) {
      debugPrint(
          '🧹 StoryCleanupService: Iniciando limpieza de historias draft');
      try {
        await _repository.cleanupOldDraftStories();
        _lastCleanupTime = now;
        debugPrint('✅ StoryCleanupService: Limpieza completada exitosamente');
      } catch (e) {
        debugPrint('❌ StoryCleanupService: Error durante la limpieza: $e');
      }
    } else {
      debugPrint(
          '🧹 StoryCleanupService: Limpieza omitida - última limpieza hace menos de 1 hora');
    }
  }
}
