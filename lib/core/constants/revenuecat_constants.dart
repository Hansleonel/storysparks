import 'dart:io';

class RevenueCatConstants {
  static const String appleApiKey = 'appl_iUnkmztHtYheiyGRCengKTwiPja';
  static const String entitlementId = 'Memory Sparks Subscriptions';

  static String get apiKey {
    if (Platform.isIOS) return appleApiKey;
    throw UnsupportedError(
        'Platform not supported yet. Only iOS is configured.');
  }
}
