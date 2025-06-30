import 'package:equatable/equatable.dart';

class StoryParams extends Equatable {
  final String memoryText;
  final String genre;
  final String?
      imagePath; // Ruta de la imagen original seleccionada por el usuario
  final String? imageDescription; // Descripción generada por IA si hay imagen
  final String? targetLanguage; // Código de idioma (ej: 'es', 'en')
  final String? authorStyle; // Estilo de autor/libro para inspirar la narrativa
  final String? authorStyleType; // Tipo: 'author', 'book', 'custom'

  const StoryParams({
    required this.memoryText,
    required this.genre,
    this.imagePath,
    this.imageDescription,
    this.targetLanguage,
    this.authorStyle,
    this.authorStyleType,
  });

  StoryParams copyWith({
    String? memoryText,
    String? genre,
    String? imagePath,
    String? imageDescription,
    String? targetLanguage,
    String? authorStyle,
    String? authorStyleType,
  }) {
    return StoryParams(
      memoryText: memoryText ?? this.memoryText,
      genre: genre ?? this.genre,
      imagePath: imagePath ?? this.imagePath,
      imageDescription: imageDescription ?? this.imageDescription,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      authorStyle: authorStyle ?? this.authorStyle,
      authorStyleType: authorStyleType ?? this.authorStyleType,
    );
  }

  @override
  List<Object?> get props => [
        memoryText,
        genre,
        imagePath,
        imageDescription,
        targetLanguage,
        authorStyle,
        authorStyleType,
      ];
}
