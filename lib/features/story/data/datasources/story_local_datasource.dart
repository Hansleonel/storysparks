import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:storysparks/core/utils/cover_image_helper.dart';
import '../../domain/entities/story.dart';
import 'package:flutter/foundation.dart';

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
      version: 4,
      onCreate: (db, version) async {
        debugPrint('📦 Database: Creando base de datos versión $version');
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            genre TEXT NOT NULL,
            memory TEXT NOT NULL,
            created_at TEXT NOT NULL,
            read_count INTEGER DEFAULT 0,
            rating REAL DEFAULT 0.0,
            user_id TEXT NOT NULL,
            title TEXT NOT NULL,
            image_url TEXT NOT NULL,
            status TEXT DEFAULT 'draft'
          )
        ''');
        debugPrint('✅ Database: Tabla creada exitosamente');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        debugPrint('🔄 Database: Actualizando de v$oldVersion a v$newVersion');

        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN user_id TEXT NOT NULL DEFAULT ""');
          debugPrint('✅ Database: v2 - Agregada columna user_id');
        }

        if (oldVersion < 3) {
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN title TEXT NOT NULL DEFAULT "Mi Historia"');
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN image_url TEXT NOT NULL DEFAULT ""');

          final List<Map<String, dynamic>> stories = await db.query(tableName);
          for (var story in stories) {
            await db.update(
              tableName,
              {'image_url': CoverImageHelper.getCoverImage(story['genre'])},
              where: 'id = ?',
              whereArgs: [story['id']],
            );
          }
          debugPrint('✅ Database: v3 - Agregadas columnas title e image_url');
        }

        if (oldVersion < 4) {
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN status TEXT DEFAULT "draft"');
          await db.update(tableName, {'status': 'saved'});
          debugPrint('✅ Database: v4 - Agregada columna status');
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
        'status': story.status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateStoryStatus(int storyId, String status) async {
    final db = await database;
    await db.update(
      tableName,
      {'status': status},
      where: 'id = ?',
      whereArgs: [storyId],
    );
  }

  Future<List<Story>> getSavedStories(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'saved'],
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
        status: maps[i]['status'] ?? 'draft',
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
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'saved'],
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
        status: maps[i]['status'] ?? 'draft',
      );
    });
  }

  Future<List<Story>> getRecentStories(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'saved'],
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
        status: maps[i]['status'] ?? 'draft',
      );
    });
  }

  Future<void> cleanupOldDraftStories() async {
    final db = await database;
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));

    final int deletedCount = await db.delete(
      tableName,
      where: 'status = ? AND created_at < ?',
      whereArgs: ['draft', twoDaysAgo.toIso8601String()],
    );

    debugPrint(
        '🧹 StoryLocalDatasource: Limpieza de historias draft completada');
    debugPrint('   - Fecha límite: ${twoDaysAgo.toIso8601String()}');
    debugPrint('   - Historias eliminadas: $deletedCount');
  }

  Future<void> updateStoryContent(Story story) async {
    if (story.id == null) {
      throw Exception('Cannot update a story without an ID');
    }

    final db = await database;
    await db.update(
      tableName,
      {
        'content': story.content,
        'created_at': story.createdAt.toIso8601String(),
        'read_count': story.readCount,
        'rating': story.rating > 0 ? story.rating : 5.0,
        'status': story.status,
        'title': story.title,
        'image_url': story.imageUrl,
      },
      where: 'id = ?',
      whereArgs: [story.id],
    );
    debugPrint(
        '✅ StoryLocalDatasource: Historia actualizada con ID: ${story.id}');
    debugPrint('   Rating: ${story.rating > 0 ? story.rating : 5.0}');
  }
}
