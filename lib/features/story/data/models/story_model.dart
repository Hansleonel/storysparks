import 'package:memorysparks/core/utils/cover_image_helper.dart';
import 'package:memorysparks/features/story/domain/entities/story.dart';

class StoryModel extends Story {
  StoryModel({
    required super.id,
    required super.content,
    required super.genre,
    required super.createdAt,
    required super.memory,
    required super.readCount,
    required super.rating,
    required super.userId,
    required super.title,
    required super.imageUrl,
    super.language = 'es',
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as int,
      content: json['content'] as String,
      genre: json['genre'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      memory: json['memory'] as String,
      readCount: json['read_count'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? 'Mi Historia',
      imageUrl: json['image_url'] as String? ??
          CoverImageHelper.getCoverImage(json['genre'] as String),
      language: json['language'] as String? ?? 'es',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'genre': genre,
      'created_at': createdAt.toIso8601String(),
      'memory': memory,
      'read_count': readCount,
      'rating': rating,
      'user_id': userId,
      'title': title,
      'image_url': imageUrl,
      'language': language,
    };
  }
}
