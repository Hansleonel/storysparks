class Story {
  final int? id;
  final String content;
  final String genre;
  final DateTime createdAt;
  final String memory;
  final int readCount;

  Story({
    this.id,
    required this.content,
    required this.genre,
    required this.createdAt,
    required this.memory,
    this.readCount = 0,
  });

  Story copyWith({
    int? id,
    String? content,
    String? genre,
    DateTime? createdAt,
    String? memory,
    int? readCount,
  }) {
    return Story(
      id: id ?? this.id,
      content: content ?? this.content,
      genre: genre ?? this.genre,
      createdAt: createdAt ?? this.createdAt,
      memory: memory ?? this.memory,
      readCount: readCount ?? this.readCount,
    );
  }
}
