import 'package:sqflite/sqflite.dart';
import 'package:storysparks/features/profile/data/models/story_model.dart';

abstract class StoryLocalDataSource {
  Future<List<StoryModel>> getUserStories();
}

class StoryLocalDataSourceImpl implements StoryLocalDataSource {
  final Database database;

  StoryLocalDataSourceImpl(this.database);

  @override
  Future<List<StoryModel>> getUserStories() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'stories',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => StoryModel.fromJson(maps[i]));
  }
}
