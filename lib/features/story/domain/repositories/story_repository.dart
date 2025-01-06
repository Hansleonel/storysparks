import '../entities/story.dart';

abstract class StoryRepository {
  Future<Story> generateStory({
    required String memory,
    required String genre,
  });
  Future<int> saveStory(Story story);
  Future<List<Story>> getSavedStories();
  Future<void> updateRating(int storyId, double rating);
  Future<void> deleteStory(int storyId);
  Future<void> incrementReadCount(int storyId);
  Future<List<Story>> getPopularStories();
  Future<List<Story>> getRecentStories();
}
