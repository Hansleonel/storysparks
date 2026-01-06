class Story {
  final int? id;
  final String content;
  final String genre;
  final DateTime createdAt;
  final String memory;
  final int readCount;
  final double rating;
  final String userId;
  final String title;
  final String imageUrl;
  final String? customImagePath;
  final String status;
  final String language;

  Story({
    this.id,
    required this.content,
    required this.genre,
    required this.createdAt,
    required this.memory,
    this.readCount = 0,
    this.rating = 0.0,
    required this.userId,
    required this.title,
    required this.imageUrl,
    this.customImagePath,
    this.status = 'draft',
    this.language = 'es',
  });

  Story copyWith({
    int? id,
    String? content,
    String? genre,
    DateTime? createdAt,
    String? memory,
    int? readCount,
    double? rating,
    String? userId,
    String? title,
    String? imageUrl,
    String? customImagePath,
    String? status,
    String? language,
  }) {
    return Story(
      id: id ?? this.id,
      content: content ?? this.content,
      genre: genre ?? this.genre,
      createdAt: createdAt ?? this.createdAt,
      memory: memory ?? this.memory,
      readCount: readCount ?? this.readCount,
      rating: rating ?? this.rating,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      customImagePath: customImagePath ?? this.customImagePath,
      status: status ?? this.status,
      language: language ?? this.language,
    );
  }
}
