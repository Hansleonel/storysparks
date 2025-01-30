import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:storysparks/core/utils/cover_image_helper.dart';
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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stories.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            genre TEXT NOT NULL,
            memory TEXT NOT NULL,
            created_at TEXT NOT NULL,
            read_count INTEGER DEFAULT 0,
            rating REAL DEFAULT 0.0,
            user_id TEXT NOT NULL,
            title TEXT NOT NULL,
            image_url TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN user_id TEXT NOT NULL DEFAULT ""');
        }
        if (oldVersion < 3) {
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN title TEXT NOT NULL DEFAULT "Mi Historia"');
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN image_url TEXT NOT NULL DEFAULT ""');
          // Actualizar imageUrl basado en el género para historias existentes
          final List<Map<String, dynamic>> stories = await db.query(tableName);
          for (var story in stories) {
            await db.update(
              tableName,
              {'image_url': CoverImageHelper.getCoverImage(story['genre'])},
              where: 'id = ?',
              whereArgs: [story['id']],
            );
          }
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
        'created_at': story.createdAt.toIso8601String(),
        'read_count': story.readCount,
        'rating': story.rating,
        'user_id': story.userId,
        'title': story.title,
        'image_url': story.imageUrl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Story>> getSavedStories(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Story(
        id: maps[i]['id'],
        content: maps[i]['content'],
        genre: maps[i]['genre'],
        memory: maps[i]['memory'],
        createdAt: DateTime.parse(maps[i]['created_at']),
        readCount: maps[i]['read_count'] ?? 0,
        rating: maps[i]['rating'] ?? 0.0,
        userId: maps[i]['user_id'],
        title: maps[i]['title'] ?? 'Mi Historia',
        imageUrl: maps[i]['image_url'] ??
            CoverImageHelper.getCoverImage(maps[i]['genre']),
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

  Future<void> deleteStory(int id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementReadCount(int id) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE $tableName 
      SET read_count = read_count + 1 
      WHERE id = ?
    ''', [id]);
  }

  Future<List<Story>> getPopularStories(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'read_count DESC',
      limit: 10,
    );

    return List.generate(maps.length, (i) {
      return Story(
        id: maps[i]['id'],
        content: maps[i]['content'],
        genre: maps[i]['genre'],
        memory: maps[i]['memory'],
        createdAt: DateTime.parse(maps[i]['created_at']),
        readCount: maps[i]['read_count'] ?? 0,
        rating: maps[i]['rating'] ?? 0.0,
        userId: maps[i]['user_id'],
        title: maps[i]['title'] ?? 'Mi Historia',
        imageUrl: maps[i]['image_url'] ??
            CoverImageHelper.getCoverImage(maps[i]['genre']),
      );
    });
  }

  Future<List<Story>> getRecentStories(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: 10,
    );

    return List.generate(maps.length, (i) {
      return Story(
        id: maps[i]['id'],
        content: maps[i]['content'],
        genre: maps[i]['genre'],
        memory: maps[i]['memory'],
        createdAt: DateTime.parse(maps[i]['created_at']),
        readCount: maps[i]['read_count'] ?? 0,
        rating: maps[i]['rating'] ?? 0.0,
        userId: maps[i]['user_id'],
        title: maps[i]['title'] ?? 'Mi Historia',
        imageUrl: maps[i]['image_url'] ??
            CoverImageHelper.getCoverImage(maps[i]['genre']),
      );
    });
  }
}
