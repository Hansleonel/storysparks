import 'package:flutter/material.dart' show Locale, WidgetsBinding, debugPrint;
import 'package:memorysparks/core/domain/repositories/locale_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleRepositoryImpl implements LocaleRepository {
  static const String _localeKey = 'app_locale';

  @override
  Future<Locale> getCurrentLocale() async {
    debugPrint('🌎 LocaleRepository: Obteniendo idioma de la aplicación...');

    try {
      // 1. Intentar obtener el idioma guardado en la aplicación
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);

      if (savedLocaleCode != null) {
        debugPrint(
            '🌎 LocaleRepository: Idioma de la app encontrado: $savedLocaleCode');
        return Locale(savedLocaleCode);
      }

      debugPrint(
          '🌎 LocaleRepository: No hay idioma guardado, usando idioma del sistema');
    } catch (e) {
      debugPrint('⚠️ LocaleRepository: Error al leer preferencias: $e');
    }

    // 2. Si no hay idioma guardado, usar el idioma del sistema
    final bindingLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final String systemLocaleTag = bindingLocale.toLanguageTag();

    debugPrint('🌎 LocaleRepository: Locale del sistema: $systemLocaleTag');

    // Use the locale tag (e.g., "es-ES", "en-US")
    final List<String> parts = systemLocaleTag.split('-');
    final String languageCode = parts[0].toLowerCase();

    debugPrint('🌎 LocaleRepository: Código de idioma extraído: $languageCode');

    return Locale(languageCode);
  }
}
