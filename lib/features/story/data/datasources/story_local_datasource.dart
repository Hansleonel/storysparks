import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/story.dart';

class StoryLocalDatasource {
  static Database? _database;
  static const String tableName = 'stories';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'story_database.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            genre TEXT NOT NULL,
            memory TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
      version: 1,
    );
  }

  Future<int> saveStory(Story story) async {
    final db = await database;
    return await db.insert(
      tableName,
      {
        'content': story.content,
        'genre': story.genre,
        'memory': story.memory,
        'createdAt': story.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Story>> getSavedStories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    return List.generate(maps.length, (i) {
      return Story(
        content: maps[i]['content'],
        genre: maps[i]['genre'],
        memory: maps[i]['memory'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
      );
    });
  }

  Future<void> deleteStory(int id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
