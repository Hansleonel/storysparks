import 'package:pdf/pdf.dart';

class PdfConstants {
  static const Map<String, String> genreTitles = {
    'happy': 'To the joy of my life',
    'sad': 'In memory of our time',
    'romantic': 'To the love of my life',
    'nostalgic': 'To the memories we shared',
    'adventure': 'To the adventures we lived',
    'family': 'To my beloved family',
  };

  static const String signature = 'Created with ❤️ using StorySparks';

  // PDF styling constants
  static const double marginTop = 70.0;
  static const double marginHorizontal = 40.0;
  static const double titleFontSize = 42.0;
  static const double contentFontSize = 16.0;
  static const double signatureFontSize = 14.0;
  static const double imageSize = 160.0;
  static const double spacingAfterHeader = 40.0;
  static const double spacingBeforeSignature = 30.0;

  // Layout constants
  static const double headerSpacing = 16.0;
  static const double contentLineHeight = 1.2;
  static const double titleLineHeight = 1.2;

  // Colores
  static final bgColor = PdfColor.fromHex('#FFF5F5');
  static final textColor = PdfColor.fromHex('#2D3748');
  static final accentColor = PdfColor.fromHex('#FF6B6B');
}
