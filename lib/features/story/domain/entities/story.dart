class Story {
  final int? id;
  final String content;
  final String genre;
  final String memory;
  final DateTime createdAt;
  final int readCount;
  final double rating;
  final String userId;
  final bool isVisible;

  Story({
    this.id,
    required this.content,
    required this.genre,
    required this.memory,
    required this.createdAt,
    this.readCount = 0,
    this.rating = 0.0,
    required this.userId,
    this.isVisible = false,
  });

  Story copyWith({
    int? id,
    String? content,
    String? genre,
    String? memory,
    DateTime? createdAt,
    int? readCount,
    double? rating,
    String? userId,
    bool? isVisible,
  }) {
    return Story(
      id: id ?? this.id,
      content: content ?? this.content,
      genre: genre ?? this.genre,
      memory: memory ?? this.memory,
      createdAt: createdAt ?? this.createdAt,
      readCount: readCount ?? this.readCount,
      rating: rating ?? this.rating,
      userId: userId ?? this.userId,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
