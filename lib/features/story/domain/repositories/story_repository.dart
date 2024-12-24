import '../entities/story.dart';

abstract class StoryRepository {
  Future<Story> generateStory({
    required String memory,
    required String genre,
  });
}
