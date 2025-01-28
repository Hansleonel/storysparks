import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            genre TEXT NOT NULL,
            memory TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            readCount INTEGER DEFAULT 0,
            rating REAL DEFAULT 0.0,
            userId TEXT NOT NULL,
            isVisible INTEGER DEFAULT 0,
            updated_at TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN userId TEXT NOT NULL DEFAULT ""');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE $tableName ADD COLUMN updated_at TEXT');
        }
        if (oldVersion < 4) {
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN isVisible INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<int> saveStory(Story story) async {
    debugPrint('💾 LocalDatasource: Iniciando guardado en SQLite...');
    final db = await database;
    try {
      final id = await db.insert(
        tableName,
        {
          'content': story.content,
          'genre': story.genre,
          'memory': story.memory,
          'createdAt': story.createdAt.toIso8601String(),
          'readCount': story.readCount,
          'rating': story.rating,
          'userId': story.userId,
          'isVisible': story.isVisible ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('✅ LocalDatasource: Historia guardada con ID: $id');
      return id;
    } catch (e) {
      debugPrint('❌ LocalDatasource: Error al guardar en SQLite: $e');
      throw Exception('Error al guardar en base de datos local: $e');
    }
  }

  Future<List<Story>> getSavedStories(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId],
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
        userId: maps[i]['userId'],
        isVisible: maps[i]['isVisible'] == 1,
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
      SET readCount = readCount + 1 
      WHERE id = ?
    ''', [id]);
  }

  Future<List<Story>> getPopularStories(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'userId = ? AND isVisible = 1',
      whereArgs: [userId],
      orderBy: 'readCount DESC',
    );
    return List.generate(maps.length, (i) => _mapToStory(maps[i]));
  }

  Future<List<Story>> getRecentStories(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'userId = ? AND isVisible = 1',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => _mapToStory(maps[i]));
  }

  Story _mapToStory(Map<String, dynamic> map) {
    return Story(
      id: map['id'],
      content: map['content'],
      genre: map['genre'],
      memory: map['memory'],
      createdAt: DateTime.parse(map['createdAt']),
      readCount: map['readCount'] ?? 0,
      rating: map['rating'] ?? 0.0,
      userId: map['userId'],
      isVisible: map['isVisible'] == 1,
    );
  }

  Future<void> updateStory(Story story) async {
    debugPrint('📝 LocalDatasource: Actualizando historia en SQLite...');
    try {
      final db = await database;
      await db.update(
        tableName,
        {
          'content': story.content,
        },
        where: 'id = ?',
        whereArgs: [story.id],
      );
      debugPrint('✅ LocalDatasource: Historia actualizada exitosamente');
    } catch (e) {
      debugPrint('❌ LocalDatasource: Error al actualizar en SQLite: $e');
      throw Exception('Error al actualizar en base de datos local: $e');
    }
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stories.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  Future<Story> getStoryById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('Historia no encontrada');
    }

    return Story(
      id: maps[0]['id'],
      content: maps[0]['content'],
      genre: maps[0]['genre'],
      memory: maps[0]['memory'],
      createdAt: DateTime.parse(maps[0]['createdAt']),
      readCount: maps[0]['readCount'] ?? 0,
      rating: maps[0]['rating'] ?? 0.0,
      userId: maps[0]['userId'],
      isVisible: maps[0]['isVisible'] == 1,
    );
  }
}
