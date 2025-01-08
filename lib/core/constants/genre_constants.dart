import 'package:flutter/material.dart';

enum Genre { happy, sad, romantic, nostalgic, adventure, family }

extension GenreExtension on Genre {
  String get key {
    switch (this) {
      case Genre.happy:
        return 'genreHappy';
      case Genre.sad:
        return 'genreSad';
      case Genre.romantic:
        return 'genreRomantic';
      case Genre.nostalgic:
        return 'genreNostalgic';
      case Genre.adventure:
        return 'genreAdventure';
      case Genre.family:
        return 'genreFamily';
    }
  }

  IconData get icon {
    switch (this) {
      case Genre.happy:
        return Icons.sentiment_very_satisfied;
      case Genre.sad:
        return Icons.sentiment_very_dissatisfied;
      case Genre.romantic:
        return Icons.favorite;
      case Genre.nostalgic:
        return Icons.hourglass_empty;
      case Genre.adventure:
        return Icons.explore;
      case Genre.family:
        return Icons.family_restroom;
    }
  }
}

// Mantener las constantes por compatibilidad con el código existente
class GenreConstants {
  static const HAPPY = 'happy';
  static const SAD = 'sad';
  static const ROMANTIC = 'romantic';
  static const NOSTALGIC = 'nostalgic';
  static const ADVENTURE = 'adventure';
  static const FAMILY = 'family';

  static Genre fromString(String value) {
    switch (value.toLowerCase()) {
      case HAPPY:
        return Genre.happy;
      case SAD:
        return Genre.sad;
      case ROMANTIC:
        return Genre.romantic;
      case NOSTALGIC:
        return Genre.nostalgic;
      case ADVENTURE:
        return Genre.adventure;
      case FAMILY:
        return Genre.family;
      default:
        throw ArgumentError('Invalid genre: $value');
    }
  }

  static String toStringValue(Genre genre) {
    switch (genre) {
      case Genre.happy:
        return HAPPY;
      case Genre.sad:
        return SAD;
      case Genre.romantic:
        return ROMANTIC;
      case Genre.nostalgic:
        return NOSTALGIC;
      case Genre.adventure:
        return ADVENTURE;
      case Genre.family:
        return FAMILY;
    }
  }
}
