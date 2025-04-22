import 'package:flutter/material.dart' show Locale, WidgetsBinding, debugPrint;
import 'package:memorysparks/core/domain/repositories/locale_repository.dart';

class LocaleRepositoryImpl implements LocaleRepository {
  @override
  Future<Locale> getCurrentLocale() async {
    debugPrint('🌎 LocaleRepository: Detectando idioma del dispositivo...');

    // Prioritize WidgetsBinding if available (more robust)
    final bindingLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final String systemLocaleTag = bindingLocale.toLanguageTag();

    debugPrint('🌎 LocaleRepository: Locale del sistema: $systemLocaleTag');
    debugPrint(
        '🌎 LocaleRepository: Locale completo: ${bindingLocale.toString()}');

    // Las preferencias de localización de Flutter
    final List<Locale> preferredLocales =
        WidgetsBinding.instance.platformDispatcher.locales;
    debugPrint(
        '🌎 LocaleRepository: Localizaciones preferidas: $preferredLocales');

    // Use the locale tag (e.g., "es-ES", "en-US")
    final List<String> parts =
        systemLocaleTag.split('-'); // Use hyphen as separator for tags
    final String languageCode =
        parts[0].toLowerCase(); // Normalize to lowercase

    debugPrint('🌎 LocaleRepository: Código de idioma extraído: $languageCode');

    return Locale(languageCode);
  }
}
