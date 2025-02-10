import 'package:equatable/equatable.dart';

class StoryPdf extends Equatable {
  final String title;
  final String content;
  final String genre;
  final String authorName;
  final DateTime generatedDate;
  final String coverImagePath;

  const StoryPdf({
    required this.title,
    required this.content,
    required this.genre,
    required this.authorName,
    required this.generatedDate,
    required this.coverImagePath,
  });

  @override
  List<Object?> get props => [
        title,
        content,
        genre,
        authorName,
        generatedDate,
        coverImagePath,
      ];
}
