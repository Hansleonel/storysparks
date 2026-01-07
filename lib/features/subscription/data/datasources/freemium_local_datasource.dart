import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:memorysparks/core/utils/cover_image_helper.dart';

/// Datasource for managing freemium quotas
/// Instead of maintaining a separate counter, we query the stories table
/// to get the accurate count of saved stories for a user.
class FreemiumLocalDatasource {
  static Database? _database;
  static const String _storiesTable = 'stories';
  static const int maxFreeStories = 3;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stories.db');

    // Open the stories database with proper onCreate
    return await openDatabase(
      path,
      version: 6,
      onCreate: (db, version) async {
        debugPrint('📦 FreemiumLocalDatasource: Creando base de datos versión $version');
        await _onCreate(db, version);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        debugPrint('🔄 FreemiumLocalDatasource: Actualizando de v$oldVersion a v$newVersion');

        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE $_storiesTable ADD COLUMN user_id TEXT NOT NULL DEFAULT ""');
          debugPrint('✅ Database: v2 - Agregada columna user_id');
        }

        if (oldVersion < 3) {
          await db.execute(
              'ALTER TABLE $_storiesTable ADD COLUMN title TEXT NOT NULL DEFAULT "Mi Historia"');
          await db.execute(
              'ALTER TABLE $_storiesTable ADD COLUMN image_url TEXT NOT NULL DEFAULT ""');

          final List<Map<String, dynamic>> stories = await db.query(_storiesTable);
          for (var story in stories) {
            await db.update(
              _storiesTable,
              {'image_url': CoverImageHelper.getCoverImage(story['genre'])},
              where: 'id = ?',
              whereArgs: [story['id']],
            );
          }
          debugPrint('✅ Database: v3 - Agregadas columnas title e image_url');
        }

        if (oldVersion < 4) {
          await db.execute(
              'ALTER TABLE $_storiesTable ADD COLUMN status TEXT DEFAULT "draft"');
          await db.update(_storiesTable, {'status': 'saved'});
          debugPrint('✅ Database: v4 - Agregada columna status');
        }

        if (oldVersion < 5) {
          await db.execute(
              'ALTER TABLE $_storiesTable ADD COLUMN custom_image_path TEXT');
          debugPrint('✅ Database: v5 - Agregada columna custom_image_path');
        }

        if (oldVersion < 6) {
          await db.execute(
              'ALTER TABLE $_storiesTable ADD COLUMN language TEXT DEFAULT "es"');
          debugPrint('✅ Database: v6 - Agregada columna language');
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_storiesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        genre TEXT NOT NULL,
        created_at TEXT NOT NULL,
        memory TEXT NOT NULL,
        read_count INTEGER DEFAULT 0,
        rating REAL DEFAULT 5.0,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        image_url TEXT NOT NULL,
        custom_image_path TEXT,
        status TEXT DEFAULT 'draft',
        language TEXT DEFAULT 'es'
      )
    ''');
    debugPrint('✅ FreemiumLocalDatasource: Tabla stories creada exitosamente');
  }

  /// Get the count of saved stories for a user
  Future<int> getSavedStoryCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_storiesTable WHERE user_id = ? AND status = ?',
      [userId, 'saved'],
    );

    final count = Sqflite.firstIntValue(result) ?? 0;
    debugPrint(
        '📊 FreemiumLocalDatasource: Usuario $userId tiene $count historias guardadas');
    return count;
  }

  /// Check if user can save more stories (has available quota)
  Future<bool> canSaveMoreStories(String userId) async {
    final count = await getSavedStoryCount(userId);
    final canSave = count < maxFreeStories;
    debugPrint(
        '📊 FreemiumLocalDatasource: ¿Puede guardar más? $canSave ($count/$maxFreeStories)');
    return canSave;
  }

  /// Get remaining story slots for free users
  Future<int> getRemainingStorySlots(String userId) async {
    final count = await getSavedStoryCount(userId);
    final remaining = maxFreeStories - count;
    return remaining > 0 ? remaining : 0;
  }
}
