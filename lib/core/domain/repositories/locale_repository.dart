import 'package:flutter/material.dart' show Locale;

abstract class LocaleRepository {
  Future<Locale> getCurrentLocale();
}
