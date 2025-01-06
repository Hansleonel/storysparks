import '../constants/genre_constants.dart';

class CoverImageHelper {
  static String getCoverImage(String genre) {
    switch (genre.toLowerCase()) {
      case GenreConstants.HAPPY:
        return 'assets/images/happiness.png';
      case GenreConstants.ROMANTIC:
        return 'assets/images/romantic.png';
      case GenreConstants.NOSTALGIC:
        return 'assets/images/nostalgic.png';
      case GenreConstants.ADVENTURE:
        return 'assets/images/adventure.png';
      case GenreConstants.FAMILY:
        return 'assets/images/familiar.png';
      case GenreConstants.SAD:
        return 'assets/images/sadness.png';
      default:
        return 'assets/images/nostalgic.png';
    }
  }
}
