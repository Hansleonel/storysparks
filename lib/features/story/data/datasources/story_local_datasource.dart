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
            createdAt TEXT NOT NULL,
            readCount INTEGER DEFAULT 0,
            rating REAL DEFAULT 0.0
          )
        ''');
      },
      version: 3,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN readCount INTEGER DEFAULT 0');
        }
        if (oldVersion < 3) {
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN rating REAL DEFAULT 0.0');
        }
      },
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
        'readCount': story.readCount,
        'rating': story.rating,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Story>> getSavedStories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    return List.generate(maps.length, (i) {
      return Story(
        id: maps[i]['id'],
        content: maps[i]['content'],
        genre: maps[i]['genre'],
        memory: maps[i]['memory'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        readCount: maps[i]['readCount'] ?? 0,
        rating: maps[i]['rating'] ?? 0.0,
      );
    });
  }

  Future<void> updateRating(int id, double rating) async {
    final db = await database;
    await db.update(
      tableName,
      {'rating': rating},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Story>> getPopularStories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'readCount DESC, rating DESC',
      limit: 10,
    );

    return List.generate(maps.length, (i) {
      return Story(
        id: maps[i]['id'],
        content: maps[i]['content'],
        genre: maps[i]['genre'],
        memory: maps[i]['memory'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        readCount: maps[i]['readCount'] ?? 0,
        rating: maps[i]['rating'] ?? 0.0,
      );
    });
  }

  Future<List<Story>> getRecentStories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'createdAt DESC',
      limit: 10,
    );

    return List.generate(maps.length, (i) {
      return Story(
        id: maps[i]['id'],
        content: maps[i]['content'],
        genre: maps[i]['genre'],
        memory: maps[i]['memory'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        readCount: maps[i]['readCount'] ?? 0,
        rating: maps[i]['rating'] ?? 0.0,
      );
    });
  }

  Future<void> incrementReadCount(int id) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE $tableName 
      SET readCount = readCount + 1 
      WHERE id = ?
    ''', [id]);
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
