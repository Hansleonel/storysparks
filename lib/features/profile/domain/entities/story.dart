import 'package:equatable/equatable.dart';

class Story extends Equatable {
  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime createdAt;

  const Story({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, content, imageUrl, createdAt];
}
